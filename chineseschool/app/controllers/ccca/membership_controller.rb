class Ccca::MembershipController < ApplicationController

  verify :only => [:search_by_family_phone, :search_by_family_street] , :method => :post,
         :add_flash => {:notice => 'Illegal GET'}, :redirect_to => {:controller => '/signout', :action => 'index'}

  def search

  end

  def search_by_family_phone
    addresses_found = Address.search_by_phone params[:phone_number]
    @families = addresses_found.collect do |address|
      if address.family.nil?
        address.person.families
      else
        address.family
      end
    end.flatten.uniq.compact
    render :action => :search_result
  end

  def search_by_family_street
    if request.post?
      # Remove grade from params before creating the new SchoolClass object due to type incompatibility (string v.s. integer)
      selected_grade_id = params[:school_class].delete :grade
      @school_class = SchoolClass.new(params[:school_class])
      @school_class.grade_id = selected_grade_id.to_i unless selected_grade_id.blank?
      return unless @school_class.valid?
      school_class_active_flags = create_new_school_class_active_flags @school_class
      SchoolClass.transaction do
        school_class_active_flags.each { |school_class_active_flag| school_class_active_flag.save! }
        @school_class.save!
      end
      flash[:notice] = 'School Class added successfully'
      redirect_to :action => :index
    end
  end
end
