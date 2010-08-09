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

  def email_and_phone_number_correct?(email, phone_number)
    puts "checking email and phone number for Person id => #{self.id}"
    if self.address
      self.addres.email_and_phone_number_correct? email, phone_number
    else
      self.families.detect do |family|
        family.address.email_and_phone_number_correct? email, phone_number
      end
    end
  end

  def self.find_people_on_record(english_first_name, english_last_name, email, phone_number)
    people_found_by_name = self.find_all_by_english_first_name_and_english_last_name english_first_name, english_last_name
    people_found_by_name.find_all do |person|
      person.email_and_phone_number_correct? email, phone_number
    end
  end
end
