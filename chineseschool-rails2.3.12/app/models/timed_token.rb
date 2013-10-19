class TimedToken < ActiveRecord::Base

  belongs_to :person

  validates_presence_of :token, :person, :expiration
  

  def generate_token
    self.token = random_string 20
  end

  def expired?
    self.expiration < Time.now
  end

  def self.has_unexpired_token_for?(person_id)
    self.all(:conditions => ['person_id = ? AND expiration >= ?', person_id, Time.now]).size > 0
  end
  
  
  private
  
  def random_string(length=10)
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    random_string = ''
    length.times { random_string << chars[rand(chars.size)] }
    random_string
  end
end
