class CreateLibraryBooks < ActiveRecord::Migration
  def self.up
    create_table :library_books do |t|
      t.string :title
      t.string :description
      t.string :publisher
      t.string :book_type
      t.boolean :checked_out
      t.text :note

      t.timestamps
    end
  end

  def self.down
    drop_table :library_books
  end
end
