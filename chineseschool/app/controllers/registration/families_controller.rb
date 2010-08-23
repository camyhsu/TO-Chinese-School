class Registration::FamiliesController < ApplicationController

  def show
    @family = Family.find_by_id(params[:id].to_i)
  end

  def new
    if request.post?
      @address = Address.new(params[:address])
      @parent_one = Person.new(params[:parent_one])
      valid_address = @address.valid?
      valid_parent_one = @parent_one.valid?
      return unless valid_address and valid_parent_one

      new_family = Family.new
      new_family.address = @address
      new_family.parent_one = @parent_one
      if new_family.save
        flash[:notice] = 'New family created successfully'
        redirect_to :action => :show, :id => new_family.id
      else
        flash.now[:notice] = 'System Error!!  Please try again or contact site administrator.'
      end
    else
      @address = Address.new
      @parent_one = Person.new
    end
  end
end
