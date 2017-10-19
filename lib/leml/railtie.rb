require 'rails/railtie'

module Leml
  class Railtie < Rails::Railtie
    unless ARGV.include? 'leml:init'
      initializer 'leml.merge_secrets' do
        config.before_initialize do
          require 'leml/core'
          Leml::Core.new.merge_secrets
        end
      end
    end

    rake_tasks do
      load 'tasks/leml_tasks.rake'
    end
  end
end
