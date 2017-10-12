require 'rails'
require 'leml/errors'

module Leml
  class Core
    KEY_FILE = Rails.root.join('config', 'leml.key')
    SECRETS = Rails.root.join('config', 'leml.yml')

    class << self
      def setup
        key_initialize
        yaml_initialize
        complete_message
      end

      private

      def key_initialize
        confirm_initialize(KEY_FILE) if File.exist?(KEY_FILE)
        File.open(KEY_FILE, 'w') do |file|
          file.puts(SecureRandom.hex(16))
        end
      end

      def yaml_initialize
        confirm_initialize(SECRETS) if File.exist?(SECRETS)
        File.open(SECRETS, 'w') do |file|
          file.puts(yaml_template)
        end
      end

      def confirm_initialize(file)
        @confirm ||= get_confirm_from_stdin == 'Y'
        abort unless @confirm
      end

      def get_confirm_from_stdin
        puts 'Already exist key or leml.yaml, in your project, continue initialize? [Y,n]'
        loop do
          print '>>'
          stdin = $stdin.gets.chomp
          return stdin if stdin =~ /^(Y|n)$/
        end
      end

      def yaml_template
        <<~EOS
          # leml is provide only leaf encrypted secrets
          # only keys is readble, but value is no way.
          # notation is same of secrets, needs environments
        EOS
      end

      def complete_message
        print <<~EOS
          \e[32mComplete!
          \e[32mcreate  \e[0mconfig/leml.key
          \e[32mcreate  \e[0mconfig/leml.yml

          \e[33mCaution \e[0mDon't forget add key file in gitignore
        EOS
      end
    end

    def initialize
      @key = File.exist?(KEY_FILE) ? File.read(KEY_FILE).chop : ENV['LEML_KEY']
      raise NoLemlKeyError if @key.blank?
      @encryptor = ActiveSupport::MessageEncryptor.new(@key, cipher: 'aes-256-cbc')
      @secrets = YAML.load_file(SECRETS)
    end

    def merge_secrets
      return unless @key.present? && File.exists?(SECRETS)
      Rails.application.secrets.merge!(decrypt(@secrets)[Rails.env].deep_symbolize_keys) if @secrets
    end

    def edit
      raise NoEditorError if ENV['EDITOR'].blank?
      Dir.mktmpdir do |dir|
        tmp_file = create_decrypted_tmp_file(dir)
        system("#{ENV['EDITOR']} #{tmp_file.to_s}")
        reload_secrets_file(tmp_file)
        puts 'OK, your secrets is encrypted.'
      end
    end

    def show
      return unless @secrets
      print(decrypt(@secrets).to_yaml)
    end

    private

    def encrypt(raw_secret_hash)
      raw_secret_hash.map do |key, value|
        [
          key,
          value.kind_of?(Hash) ? encrypt(value) : encrypt_value(value)
        ]
      end.to_h
    end

    def decrypt(secret_hash)
      secret_hash.map do |key, value|
        [
          key,
          value.kind_of?(Hash) ? decrypt(value) : decrypt_value(value)
        ]
      end.to_h
    end

    def encrypt_value(value)
      @encryptor.encrypt_and_sign(value)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      raise InvalidLemlKey
    end

    def decrypt_value(value)
      @encryptor.decrypt_and_verify(value)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      raise InvalidLemlKey
    end

    def no_editor
      puts 'No editor, please set environment variable.'
      puts 'ex) EDITOR=vim bundle exec rake leml:edit'
      abort
    end

    def create_decrypted_tmp_file(dir)
      file = File.join(dir, 'tmp_leml.yml')
      File.open(file, 'w') do |file|
        file.puts(decrypt(@secrets).to_yaml) if @secrets
      end
      file
    end

    def reload_secrets_file(tmp_file)
      raw_secrets = YAML.load_file(tmp_file)
      return unless raw_secrets
      File.open(SECRETS, 'w') do |file|
        file.puts encrypt(raw_secrets).to_yaml
      end
    end
  end
end
