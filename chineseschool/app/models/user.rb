require 'digest/sha2'

class User < ActiveRecord::Base
  
  has_and_belongs_to_many :roles
  belongs_to :person

  validates_presence_of :username, :person
  validates_uniqueness_of :username

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

  def password_correct?(passwd)
    User.hash_password(passwd, self.password_salt) == self.password_hash
  end
  
  
  def self.hash_password(password, salt)
    Digest::SHA256.hexdigest(password + salt)
  end

  def self.authenticate(username, passwd)
    user_found = self.find_by_username(username)
    return nil if user_found.nil?
    return nil if self.hash_password(passwd, user_found.password_salt) != user_found.password_hash
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
