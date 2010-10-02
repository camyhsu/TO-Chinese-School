class SchoolClassesAddShortNameColumn < ActiveRecord::Migration
  def self.up
    add_column :school_classes, :short_name, :string
  end

  def self.down
    remove_column :school_classes, :short_name
  end
end
