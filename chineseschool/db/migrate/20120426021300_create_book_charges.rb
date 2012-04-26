class CreateBookCharges < ActiveRecord::Migration
  def self.up
    create_table :book_charges do |t|
      t.integer :grade_id, :null => false
      t.integer :school_year_id, :null => false
      t.integer :book_charge_in_cents, :null => false, :default => 2000

      t.timestamps
    end
    
    SchoolYear.all.each do |school_year|
      old_book_charge_in_cents = school_year.book_charge_in_cents
      Grade.all.each do |grade|
        book_charge = BookCharge.new
        book_charge.school_year = school_year
        book_charge.grade = grade
        if grade.id == 1
          # Special case for pre_k
          book_charge.book_charge_in_cents = 0
        else
          book_charge.book_charge_in_cents = old_book_charge_in_cents
        end
        book_charge.save!
      end
    end
    
    remove_column :school_years, :book_charge_in_cents
  end

  def self.down
    add_column :school_years, :book_charge_in_cents, :integer, :null => false, :default => 2000
    
    drop_table :book_charges
  end
end
