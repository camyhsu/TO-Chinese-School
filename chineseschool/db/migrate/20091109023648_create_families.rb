class CreateFamilies < ActiveRecord::Migration
  def self.up
    create_table :families do |t|
      t.integer :parent_one_id
      t.integer :parent_two_id
      t.integer :address_id

      t.timestamps
    end

    create_table :families_children, :id => false do |t|
      t.integer :family_id
      t.integer :child_id

      t.timestamps
    end
  end

  def self.down
    drop_table :families_children
    drop_table :families
  end
end
