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

  def edit
    if request.post?
      @school_class = SchoolClass.find_by_id(params[:id].to_i)
      @school_class.english_name = params[:school_class][:english_name]
      @school_class.chinese_name = params[:school_class][:chinese_name]
      @school_class.description = params[:school_class][:description]
      @school_class.location = params[:school_class][:location]
      @school_class.max_size = params[:school_class][:max_size]
      @school_class.min_age = params[:school_class][:min_age]
      @school_class.max_age = params[:school_class][:max_age]
      if params[:school_class][:grade].blank?
        @school_class.grade = nil
      else
        @school_class.grade_id = params[:school_class][:grade].to_i
      end
      if @school_class.save
        flash[:notice] = 'School Class updated successfully'
        redirect_to :action => :index
      end
    else
      @school_class = SchoolClass.find_by_id(params[:id].to_i)
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
