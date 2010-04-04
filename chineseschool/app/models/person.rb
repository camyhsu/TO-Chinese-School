class Person < ActiveRecord::Base

  belongs_to :address

  def name
    "#{chinese_name}(#{english_first_name} #{english_last_name})"
  end
  
  def families
    families_as_parent = Family.find(:all, :conditions => "parent_one_id = #{self.id} or parent_two_id = #{self.id}")
    families_as_child = Family.find(:all, :conditions => "id in (select family_id from families_children where child_id = #{self.id})")
    families_as_parent + families_as_child
  end
end
