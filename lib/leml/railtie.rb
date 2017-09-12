require 'rails/railtie'

module Leml
  class Railtie < Rails::Railtie
    initializer 'leml.merge_secrets' do
      require 'leml/core'
      Leml::Core.new.merge_secrets
    end

    rake_tasks do
      load 'tasks/leml_tasks.rake'
    end
  end
end
