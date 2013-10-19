class SchoolClassesRemoveRoomParentIdColumn < ActiveRecord::Migration
  def self.up
    remove_column :school_classes, :room_parent_id
  end

  def self.down
    add_column :school_classes, :room_parent_id, :integer
  end
end
