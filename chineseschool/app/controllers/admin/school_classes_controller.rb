class Admin::SchoolClassesController < ApplicationController

  def index
    @school_classes = SchoolClass.find(:all)
  end
end
