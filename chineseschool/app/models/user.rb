require 'digest/sha2'

class User < ActiveRecord::Base
  
  has_and_belongs_to_many :roles
  belongs_to :person

  validates :username, :person, presence: true
  validates :username, uniqueness: true

  validate :password_not_blank, :password_must_be_6_character_or_longer
  
  
  def password=(passwd)
    @password_for_validation = passwd
    create_new_salt
    self.password_hash = User.hash_password(passwd, self.password_salt)
  end

  def authorized?(controller_path, action_name)
    self.roles.any? { |role| role.authorized?(controller_path, action_name) }
  end

  def has_role?(role_name)
    self.roles.any? { |role| role.name == role_name}
  end

  def adjust_instructor_roles
    instructor_role = Role.find_by_name Role::ROLE_NAME_INSTRUCTOR
    room_parent_role = Role.find_by_name Role::ROLE_NAME_ROOM_PARENT
    self.roles.delete instructor_role
    self.roles.delete room_parent_role
    self.person.instructor_assignments_for(SchoolYear.current_school_year).each do |instructor_assignment|
      if instructor_assignment.role == InstructorAssignment::ROLE_PRIMARY_INSTRUCTOR or
          instructor_assignment.role == InstructorAssignment::ROLE_SECONDARY_INSTRUCTOR
        self.roles << instructor_role unless self.roles.include?(instructor_role)
      elsif instructor_assignment.role == InstructorAssignment::ROLE_ROOM_PARENT
        self.roles << room_parent_role unless self.roles.include?(room_parent_role)
      end
    end
  end

  def password_correct?(passwd)
    User.hash_password(passwd, self.password_salt) == self.password_hash
  end
  
  
  def self.hash_password(password, salt)
    Digest::SHA256.hexdigest(password + salt)
  end

  def self.authenticate(username, passwd)
    user_found = self.find_by_username(username.strip)
    return nil if user_found.nil?
    return nil unless user_found.password_correct?(passwd)
    user_found
  end

  
  private
  
  def create_new_salt
    self.password_salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
  end
  
  def password_not_blank
    errors.add(:password, 'not set') if self.password_hash.blank? or @password_for_validation.blank?
  end

  def password_must_be_6_character_or_longer
    errors.add(:password, 'must be 6 characters or longer') if @password_for_validation.nil? or @password_for_validation.size < 6
  end
end
