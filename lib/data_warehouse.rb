# DataWarehouse

# Need to set up local database and slaved database
require 'yaml'
require 'active_support'


class DataWarehouse
  
  class WarehouseError < Exception; end
  
  DEFAULTS = {
    'branch' => 'master',
    'ignore_paths' => [],
    'parent_database' => nil
  }
  
  def self.load_config!
    unless class_variable_defined?('@@config')
      @@config = DEFAULTS.merge(YAML.load(File.open(Rails.root + 'config/warehouse.yml')))
    end
  end
  
  def self.sync
    load_config!
    
    # TODO: Chmod sync script
    
    Kernel.exec({
          'PROJ' => @@config['project'],
          'GIT_URL' => @@config['repo'],
          'branch' => @@config['branch'],
          'DEBUG' => 'true',
          'FROM_LIB' => "",
          'JAVASCRIPTS' => "",
          'STYLESHEETS' => "",
          'RSYNC_OPTS' => @@config['ignore_paths'].collect{|p| '--exclude="' + p + '"' }.join(' ')
          },File.dirname(__FILE__) + '/../scripts/sync')
        
  end
  
  def self.setup_database_config
    load_config!
    
    local_config = YAML.load(File.open(Rails.application.config.paths.config.database.first))
    begin
      parent_config = YAML.load(File.open(Rails.root + 'config/database_parent.yml'))
                                                                          
      parent_config.keys.each {|k|
        parent_config[k] = @@config['parent_database'][k] if @@config['parent_database'] and @@config['parent_database'][k]
        parent_config[k][:local] = local_config[k]
      }

      ActiveRecord::Base.establish_connection(parent_config[Rails.env])
    rescue Errno::ENOENT
      Rails.logger.error("Unable to open parent app's database config - have you run rake warehouse:update yet?")
    end
  end
  
end