require 'digest/sha2'

class User < ActiveRecord::Base
  
  has_and_belongs_to_many :roles
  belongs_to :person

  validates_presence_of :username, :person
  
  
  def self.hash_password(password, salt)
    Digest::SHA256.hexdigest(password + salt)
  end

  
  def password=(passwd)
    create_new_salt
    self.password_hash = User.hash_password(passwd, self.password_salt)
  end


  private
  
  def create_new_salt
    self.password_salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
  end
end
