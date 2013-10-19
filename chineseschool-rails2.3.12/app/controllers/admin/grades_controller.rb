class Admin::GradesController < ApplicationController

  def index
    @grades = Grade.find(:all)
  end

end
