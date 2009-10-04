class User < ActiveRecord::Base

  has_and_belongs_to_many :roles
  belongs_to :person
  
end
