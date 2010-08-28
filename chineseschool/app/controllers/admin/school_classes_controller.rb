class Admin::SchoolClassesController < ApplicationController

  def index
    @school_classes = SchoolClass.find(:all)
    render :layout => 'jquery_datatable'
  end

  def enable
    if request.post?
      @school_class = SchoolClass.find_by_id params[:id].to_i
      flip_active_to true, @school_class
      render :action => :one_school_class, :layout => 'ajax_layout'
    end
  end

  def disable
    if request.post?
      @school_class = SchoolClass.find_by_id params[:id].to_i
      flip_active_to false, @school_class
      render :action => :one_school_class, :layout => 'ajax_layout'
    end
  end

  private

  def flip_active_to(active_flag, school_class)
    school_class.active = active_flag
    school_class.save
  end
end
