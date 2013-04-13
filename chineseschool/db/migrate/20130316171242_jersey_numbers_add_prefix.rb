class JerseyNumbersAddPrefix < ActiveRecord::Migration
  def self.up
    add_column :jersey_numbers, :prefix, :string
  end

  def self.down
    remove_column :jersey_numbers, :prefix
  end
end
