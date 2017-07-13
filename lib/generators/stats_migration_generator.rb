require 'rails/generators/active_record/migration/migration_generator'

class StatsMigrationGenerator < ActiveRecord::Generators::MigrationGenerator
  location = ActiveRecord::Generators::MigrationGenerator.instance_method(:create_migration_file).source_location.first
  source_root File.join(File.dirname(location), "templates")

  def create_migration_file
    set_local_assigns!
    validate_file_name!
    migration_template @migration_template, "db_stats/migrate/#{file_name}.rb"
  end
end
