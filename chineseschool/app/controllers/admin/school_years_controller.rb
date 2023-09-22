class Admin::SchoolYearsController < ApplicationController

  def index
    @school_years = SchoolYear.order('start_date ASC').all
  end

  def show
    @school_year = SchoolYear.find params[:id].to_i
  end

  def new
    if request.post? || request.put?
      @school_year = SchoolYear.new params[:school_year]
      set_fees_from_params
      @school_year.wire_up_previous_school_year
      if @school_year.save
        initialize_school_class_active_flags_for @school_year
        initialize_book_charges_for @school_year
        flash[:notice] = 'School Year added successfully'
        redirect_to action: :index
      end
    else
      @school_year = SchoolYear.new
    end
  end

  def edit
    if request.post? || request.put?
      @school_year = SchoolYear.find params[:id].to_i
      @school_year.name = params[:school_year][:name]
      @school_year.description = params[:school_year][:description]
      set_date_if_original_in_future :start_date
      set_date_if_original_in_future :end_date
      @school_year.age_cutoff_month = params[:school_year][:age_cutoff_month]
      set_fees_from_params
      set_date_if_original_in_future :early_registration_start_date
      set_date_if_original_in_future :early_registration_end_date
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
        redirect_to action: :show, id: @school_year
      end
    else
      @school_year = SchoolYear.find params[:id].to_i
    end
  end
  
  def edit_book_charge
    @school_year = SchoolYear.find params[:id].to_i
    @book_charges = BookCharge.find_all_for @school_year
    if request.post? || request.put?
      @book_charges.each do |book_charge|
        book_charge.book_charge = params[:book_charge][book_charge.id.to_s].to_f
        unless book_charge.valid?
          @book_charge_with_error = book_charge
          return
        end
      end
      begin
        BookCharge.transaction do
          @book_charges.each { |book_charge| book_charge.save! }
        end
      rescue => e
        puts '======================================'
        puts e.inspect
        puts '======================================'
        flash.now[:notice] = e.message
        return
      end
      flash[:notice] = 'Book Charge updated successfully'
      redirect_to action: :show, id: @school_year
    end
  end

  def toggle_auto_class_assignment
    @school_year = SchoolYear.find params[:id].to_i
    @school_year.auto_class_assignment = !@school_year.auto_class_assignment
    @school_year.save
    redirect_to action: :index
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
  
  def initialize_book_charges_for(school_year)
    Grade.all.each do |grade|
      book_charge = BookCharge.new
      book_charge.school_year = school_year
      book_charge.grade = grade
      book_charge.book_charge_in_cents = 2000
      book_charge.save!
    end
  end

  def set_date_if_original_in_future(date_attribute_symbol)
    original_value = @school_year.send date_attribute_symbol
    return unless original_value.nil? or original_value >= PacificDate.today
    @school_year.send((date_attribute_symbol.to_s + '=').to_sym, parse_date(params[:school_year][date_attribute_symbol]))
  end

  def set_fees_from_params
    @school_year.registration_fee = params[:school_year][:registration_fee].to_f
    @school_year.early_registration_tuition = params[:school_year][:early_registration_tuition].to_f
    @school_year.tuition = params[:school_year][:tuition].to_f
    @school_year.tuition_discount_for_three_or_more_child = params[:school_year][:tuition_discount_for_three_or_more_child].to_f
    @school_year.tuition_discount_for_pre_k = params[:school_year][:tuition_discount_for_pre_k].to_f
    @school_year.tuition_discount_for_instructor = params[:school_year][:tuition_discount_for_instructor].to_f
    @school_year.elective_class_fee = params[:school_year][:elective_class_fee].to_f
    @school_year.pva_membership_due = params[:school_year][:pva_membership_due].to_f
    @school_year.ccca_membership_due = params[:school_year][:ccca_membership_due].to_f
  end
end
