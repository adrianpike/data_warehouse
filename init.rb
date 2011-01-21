ActiveSupport::Dependencies.autoload_paths << "#{RAILS_ROOT}/app/parent_models"

# TODO: set this up as an initializer but it skips it for the update config :/
DataWarehouse.setup_database_config