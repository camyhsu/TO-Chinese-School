class SchoolClass < ActiveRecord::Base

  belongs_to :grade
  belongs_to :room_parent, :class_name => 'Person'
  
end
