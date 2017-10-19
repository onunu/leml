require 'test_helper'
require 'yaml'

class Leml::Test < ActiveSupport::TestCase
  setup do
    @leml = Leml::Core.new
    def @leml.secrets
      @secrets
    end
    def @leml.test_decrypt
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
end
