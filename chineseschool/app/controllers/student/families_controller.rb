class Student::FamiliesController < ApplicationController

  before_filter :action_authorized?

  def edit_address
    @family = Family.find_by_id params[:id].to_i
    @address = @family.address
    if request.post?
      if @address.update_attributes params[:address]
        flash[:notice] = 'Family address updated successfully'
        redirect_to :controller => '/home', :action => :index and return
      end
    end
    render :template => '/registration/families/edit_address'
  end

  private

  def action_authorized?
    family = Family.find_by_id params[:id].to_i
    if family.parent_one_is?(@user.person) or family.parent_two_is?(@user.person)
      return true
    else
      flash[:notice] = "Access to requested family data not authorized"
      redirect_to :controller => '/home', :action => :index and return false
    end
  end
end
