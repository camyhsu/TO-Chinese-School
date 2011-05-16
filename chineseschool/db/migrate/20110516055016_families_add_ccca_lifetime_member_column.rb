class FamiliesAddCccaLifetimeMemberColumn < ActiveRecord::Migration
  def self.up
    add_column :families, :ccca_lifetime_member, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :families, :ccca_lifetime_member
  end
end
