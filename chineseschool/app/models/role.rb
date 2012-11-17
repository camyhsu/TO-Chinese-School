class Role < ActiveRecord::Base

  ROLE_NAME_SUPER_USER = 'Super User'
  ROLE_NAME_PRINCIPAL = 'Principal'
  ROLE_NAME_REGISTRATION_OFFICER = 'Registration Officer'
  ROLE_NAME_ACCOUNTING_OFFICER = 'Accounting Officer'
  ROLE_NAME_ACTIVITY_OFFICER = 'Activity Officer'
  ROLE_NAME_COMMUNICATION_OFFICER = 'Communication Officer'
  ROLE_NAME_INSTRUCTION_OFFICER = 'Instruction Officer'
  ROLE_NAME_LIBRARIAN = 'Librarian'
  
  ROLE_NAME_INSTRUCTOR = 'Instructor'
  ROLE_NAME_ROOM_PARENT = 'Room Parent'
  ROLE_NAME_STUDENT_PARENT = 'Student Parent'
  
  ROLE_NAME_CCCA_STAFF = 'CCCA Staff'

  has_and_belongs_to_many :users
  has_and_belongs_to_many :rights, :order => 'controller ASC, action ASC'

  validates_presence_of :name
  validates_uniqueness_of :name

  def authorized?(controller_path, action_name)
    return true if self.name == ROLE_NAME_SUPER_USER
    self.rights.any? { |right| right.authorized?(controller_path, action_name) }
  end

  def self.find_people_with_role(role_name)
    # Protect against searching for superuser
    return nil if role_name == ROLE_NAME_SUPER_USER
    # Not searching for student parent since that will return too many people
    return nil if role_name == ROLE_NAME_STUDENT_PARENT
    role = Role.first :conditions => ['name = ?', role_name]
    role.users.collect { |user| user.person }
  end
end
