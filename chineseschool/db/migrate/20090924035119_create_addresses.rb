class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :street
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :home_phone
      t.string :cell_phone
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
