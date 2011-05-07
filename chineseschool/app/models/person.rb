class Person < ActiveRecord::Base

  GENDER_MALE = 'M'
  GENDER_FEMALE = 'F'

  has_one :user
  belongs_to :address

  has_one :student_class_assignment, :foreign_key => 'student_id', :dependent => :destroy
  has_many :instructor_assignments, :foreign_key => 'instructor_id', :dependent => :destroy

  validates_presence_of :gender
  validates_presence_of :birth_year, :if => Proc.new { |person| person.is_a_child? }
  validates_presence_of :birth_month, :if => Proc.new { |person| person.is_a_child? }

  validates_numericality_of :birth_year, :allow_nil => true, :only_integer => true, :greater_than => 1900, :less_than => Time.now.year
  validates_numericality_of :birth_month, :allow_nil => true, :only_integer => true, :greater_than => 0, :less_than => 13

  validate :name_is_not_blank, :birth_year_is_valid


  def name
    "#{chinese_name}(#{english_first_name} #{english_last_name})"
  end

  def birth_info
    return '' if birth_month.blank? or birth_year.blank?
    "#{birth_month}/#{birth_year}"
  end

  def is_a_child?
    Person.count_by_sql("SELECT COUNT(1) FROM families_children WHERE child_id = #{self.id}") > 0
  end
  
  def families
    find_families_as_parent + find_families_as_child
  end

  def find_families_as_parent
    Family.all :conditions => ["parent_one_id = ? or parent_two_id = ?", self.id, self.id]
  end

  def find_families_as_child
    Family.all :from => 'families, families_children', :conditions => ["families.id = families_children.family_id and families_children.child_id = ?", self.id]
  end

  def personal_email_address
    if self.address
      self.address.email
    else
      family_with_email = self.families.detect do |family|
        !family.address.email.blank?
      end
      return nil if family_with_email.nil?
      family_with_email.address.email
    end
  end

  def email_and_phone_number_correct?(email, phone_number)
    if self.address
      self.addres.email_and_phone_number_correct? email, phone_number
    else
      self.families.detect do |family|
        family.address.email_and_phone_number_correct? email, phone_number
      end
    end
  end

  def phone_number_correct?(phone_number)
    if self.address
      self.address.phone_number_correct?
    else
      self.families.detect do |family|
        family.address.phone_number_correct? phone_number
      end
    end
  end

  def self.find_people_on_record(english_first_name, english_last_name, email, phone_number)
    people_found_by_name = self.find_all_by_english_first_name_and_english_last_name english_first_name, english_last_name
    people_found_by_name.find_all do |person|
      person.email_and_phone_number_correct? email, phone_number
    end
  end

  private
  
  def name_is_not_blank
    return unless self.english_first_name.blank? or self.english_last_name.blank?
    return unless self.chinese_name.blank?
    errors.add_to_base('Engilsh Name or Chinese Name is required')
  end

  def birth_year_is_valid
    
  end

  def birth_month_is_valid
    
  end
end
