class Admin::SchoolClassesController < ApplicationController

  def index
    @school_classes = SchoolClass.find(:all)
    render :layout => 'jquery_datatable'
  end
end
