class CreateLibraryBookCheckouts < ActiveRecord::Migration
  def self.up
    create_table :library_book_checkouts do |t|
      t.integer :library_book_id, :null => false
      t.integer :checked_out_by_id, :null => false
      t.date :checked_out_date, :null => false
      t.date :return_date
      t.text :note

      t.timestamps
    end
  end

  def self.down
    drop_table :library_book_checkouts
  end
end
