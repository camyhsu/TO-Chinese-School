class Role < ActiveRecord::Base

  has_and_belongs_to_many :users
  has_and_belongs_to_many :rights

  def authorized?(controller_path, action_name)
    
  end
end
