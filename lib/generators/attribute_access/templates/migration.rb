class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    add_column :<%= table_name %>, :read_only_attributes, :text
  end
end
