namespace :warehouse do
  desc "Updates to the latest version of your parent project's code"
  task :update => :environment do
    DataWarehouse.sync
  end
end