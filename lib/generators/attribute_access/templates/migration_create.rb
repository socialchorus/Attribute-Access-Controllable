class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :<%= table_name %> do |t|
      t.text :read_only_attributes
      
      t.timestamps
    end
  end
end
