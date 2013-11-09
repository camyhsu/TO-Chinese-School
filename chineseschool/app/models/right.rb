class Right < ActiveRecord::Base

  attr_accessible :name, :controller, :action

  has_and_belongs_to_many :roles

  def authorized?(controller_path, action_name)
    self.controller == controller_path and self.action == action_name
  end
end
