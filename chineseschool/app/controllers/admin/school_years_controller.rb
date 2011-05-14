class Admin::SchoolYearsController < ApplicationController

  def index
    @school_years = SchoolYear.all
  end

  def show
    @school_year = SchoolYear.find_by_id params[:id].to_i
  end

  def new
    if request.post?
      @school_year = SchoolYear.new params[:school_year]
      if @school_year.save
        initialize_school_class_active_flags_for @school_year
        flash[:notice] = 'School Year added successfully'
        redirect_to :action => :index
      end
    else
      @school_year = SchoolYear.new
    end
  end

  def edit
    if request.post?
      @school_year = SchoolYear.find_by_id(params[:id].to_i)
      @school_year.name = params[:school_year][:name]
      @school_year.description = params[:school_year][:description]
      set_date_if_original_in_future :start_date
      set_date_if_original_in_future :end_date
      @school_year.age_cutoff_month = params[:school_year][:age_cutoff_month]
      set_date_if_original_in_future :registration_start_date
      set_date_if_original_in_future :registration_75_percent_date
      set_date_if_original_in_future :registration_50_percent_date
      set_date_if_original_in_future :registration_end_date
      set_date_if_original_in_future :refund_75_percent_date
      set_date_if_original_in_future :refund_50_percent_date
      set_date_if_original_in_future :refund_25_percent_date
      set_date_if_original_in_future :refund_end_date
      if @school_year.save
        flash[:notice] = 'School Year updated successfully'
        redirect_to :action => :show, :id => @school_year.id
      end
    else
      @school_year = SchoolYear.find_by_id params[:id].to_i
    end
  end

  private

  def initialize_school_class_active_flags_for(school_year)
    SchoolClass.all.each do |school_class|
      school_class_active_flag = SchoolClassActiveFlag.new
      school_class_active_flag.school_class = school_class
      school_class_active_flag.school_year = school_year
      school_class_active_flag.active = true
      school_class_active_flag.save!
    end
  end

  def set_date_if_original_in_future(date_attribute_symbol)
    original_value = @school_year.send date_attribute_symbol
    return unless original_value.nil? or original_value >= Date.today
    @school_year.send((date_attribute_symbol.to_s + '=').to_sym, parse_date(params[:school_year][date_attribute_symbol]))
  end
end
