require 'rails'
require 'pry'

module Leml
  class Railtie < Rails::Engine
    initializer 'Decrypt Leml file' do
      require 'leml/core'
      Leml::Core.new.merge_secrets
    end
  end
end
