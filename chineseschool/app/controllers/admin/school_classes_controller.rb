class Admin::SchoolClassesController < ApplicationController

  verify :only => [:enable, :disable] , :method => :post, :add_flash => { :notice => 'Illegal GET' }, :redirect_to => { :action => 'index' }

  def index
    @school_classes = SchoolClass.all
    render :layout => 'jquery_datatable'
  end

  def new
    if request.post?
      # Remove grade from params before creating the new SchoolClass object due to type incompatibility (string v.s. integer)
      selected_grade_id = params[:school_class].delete :grade
      @school_class = SchoolClass.new(params[:school_class])
      @school_class.grade_id = selected_grade_id.to_i unless selected_grade_id.blank?
      if @school_class.save
        flash[:notice] = 'School Class added successfully'
        redirect_to :action => :index
      end
    else
      @school_class = SchoolClass.new
    end
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
    school_class.save!
  end
end
