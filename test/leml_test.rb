require 'test_helper'
require 'yaml'

class Leml::Test < ActiveSupport::TestCase
  setup do
    @leml = Leml::Core.new
    def @leml.secrets
      @secrets
    end
    def @leml.test_decrypt(secrets = nil)
      @secrets = secrets if secrets
      decrypt(@secrets).to_yaml
    end
    def @leml.test_encrypt(raw_secrets)
      encrypt(raw_secrets).to_yaml
    end
  end

  test "truth" do
    assert_kind_of Module, Leml
  end

  test "leml use same encrypted value when it did not edit" do
    assert_equal @leml.secrets.to_yaml, @leml.test_encrypt(YAML.load(@leml.test_decrypt))
  end

  test "leml create other encrypted value when it edited" do
    decrypt = YAML.load(@leml.test_decrypt)
    decrypt['development']['author'] = decrypt['development']['author'] * 2
    assert_not_equal @leml.secrets.to_yaml, @leml.test_encrypt(decrypt)
  end

  test "leml create other encrypted value only edited value" do
    decrypt = YAML.load(@leml.test_decrypt)
    decrypt['development']['new_value'] = "new_value"
    re_encrypt = YAML.load(@leml.test_encrypt(decrypt))

    assert_equal @leml.secrets.dig('development', 'author'), re_encrypt.dig('development', 'author')
    assert_not_equal @leml.secrets.dig('development', 'new_value'), re_encrypt.dig('development', 'new_value')
  end

  test "leml use same values still hash order changed" do
    test_keys_same = %w(aaa ccc eee fff)
    test_keys_change = %w(bbb ddd ggg)
    test_keys = (test_keys_same + test_keys_change).sort

    decrypt = YAML.load(@leml.test_decrypt)
    decrypt['development']['test_hash'] = {}.tap {|h| test_keys.map {|t| h[t] = t } }
    @leml.test_decrypt(YAML.load(@leml.test_encrypt(decrypt)))

    test_keys_change.each do |key|
      decrypt['development']['test_hash'][key] = 'change'
    end
    decrypt['development']['test_hash'] = Hash[decrypt['development']['test_hash'].sort.reverse]
    re_encrypt = YAML.load(@leml.test_encrypt(decrypt))

    assert_equal @leml.secrets.dig('development', 'author'), re_encrypt.dig('development', 'author')

    test_keys_same.each do |key|
      assert_equal @leml.secrets.dig('development', 'test_hash', key), re_encrypt.dig('development', 'test_hash', key)
    end
    test_keys_change.each do |key|
      assert_not_equal @leml.secrets.dig('development', 'test_hash', key), re_encrypt.dig('development', 'test_hash', key)
    end
  end
end
