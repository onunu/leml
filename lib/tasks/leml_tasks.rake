require 'leml/core'

namespace :leml do
  desc 'initialize secrets yaml'
  task :init => :environment do
    Leml::Core.setup
  end

  desc 'edit encrypted yaml'
  task :edit => :environment do
    Leml::Core.new.edit
  end

  desc 'show encrypted yaml'
  task :show => :environment do
    Leml::Core.new.show
  end
end
