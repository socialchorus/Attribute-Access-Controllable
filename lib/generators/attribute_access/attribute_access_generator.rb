require "rails/generators/active_record"

class AttributeAccessGenerator < ActiveRecord::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  def create_migration_file
    if (behavior == :invoke && model_exists?)
      migration_template "migration.rb", "db/migrate/add_read_only_attributes_to_#{table_name}"
    else
      migration_template "migration_create.rb", "db/migrate/create_#{table_name}"
    end
  end
  
  def generate_model
    invoke "active_record:model", [name], :migration => false unless model_exists? && behavior == :invoke
  end
  
  def inject_attribute_access_content
    class_path = class_name.to_s.split('::')
    
    indent_depth = class_path.size
    content = "  " * indent_depth + 'include AttributeAccessControllable' + "\n"
    
    inject_into_class(model_path, class_path.last, content) if model_exists?
  end
  
  private
  
  def model_exists?
    File.exists?(File.join(destination_root, model_path))
  end
  
  def model_path
    @model_path ||= File.join("app", "models", "#{file_path}.rb")
  end
end
