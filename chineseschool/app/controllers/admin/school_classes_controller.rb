class Admin::SchoolClassesController < ApplicationController

  #verify :only => [:toggle_active] , :method => :post,
  #    :add_flash => {:notice => 'Illegal GET'}, :redirect_to => {:controller => '/signout', :action => 'index'}

  def index
    @school_classes = SchoolClass.all
    @school_classes.sort! { |a, b| a.english_name <=> b.english_name }
    @current_school_year = SchoolYear.current_school_year
    @next_school_year = SchoolYear.next_school_year
    render layout: 'jquery_datatable'
  end

  def new
    if request.post? || request.put?
      # Remove grade from params before creating the new SchoolClass object due to type incompatibility (string v.s. integer)
      selected_grade_id = params[:school_class].delete :grade
      @school_class = SchoolClass.new params[:school_class]
      @school_class.grade_id = selected_grade_id.to_i unless selected_grade_id.blank?
      return unless @school_class.valid?
      school_class_active_flags = create_new_school_class_active_flags @school_class
      SchoolClass.transaction do
        school_class_active_flags.each { |school_class_active_flag| school_class_active_flag.save! }
        @school_class.save!
      end
      flash[:notice] = 'School Class added successfully'
      redirect_to action: :index
    else
      @school_class = SchoolClass.new
      @school_class.max_size = 25
    end
  end

  def edit
    if request.post? || request.put?
      @school_class = SchoolClass.find params[:id].to_i
      @school_class.english_name = params[:school_class][:english_name]
      @school_class.chinese_name = params[:school_class][:chinese_name]
      @school_class.short_name = params[:school_class][:short_name]
      @school_class.description = params[:school_class][:description]
      @school_class.location = params[:school_class][:location]
      @school_class.school_class_type = params[:school_class][:school_class_type]
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
        redirect_to action: :index
      end
    else
      @school_class = SchoolClass.find params[:id].to_i
    end
  end

  def toggle_active
    @school_class = SchoolClass.find params[:id].to_i
    @school_class.flip_active_to params[:active], params[:school_year_id].to_i
    @current_school_year = SchoolYear.current_school_year
    @next_school_year = SchoolYear.next_school_year
    render action: :one_school_class, layout: 'ajax_layout'
  end

  private

  def create_new_school_class_active_flags(school_class)
    SchoolYear.find_current_and_future_school_years.collect do |school_year|
      school_class_active_flag = SchoolClassActiveFlag.new
      school_class_active_flag.school_class = school_class
      school_class_active_flag.school_year = school_year
      school_class_active_flag.active = true
      school_class_active_flag
    end
  end
end
