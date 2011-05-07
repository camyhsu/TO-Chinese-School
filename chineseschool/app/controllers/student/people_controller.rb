class Student::PeopleController < ApplicationController

  before_filter :action_authorized?
  
  def edit
    @person = Person.find_by_id params[:id].to_i
    if request.post?
      if @person.update_attributes params[:person]
        flash[:notice] = 'Person updated successfully'
        redirect_to :controller => '/home', :action => :index and return
      end
    end
    render :template => '/registration/people/edit'
  end

  def new_address
    @person = Person.find_by_id params[:id].to_i
    if request.post?
      @address = Address.new params[:address]
      return unless @address.valid?
      @address.save!
      @person.address = @address
      @person.save!
      flash[:notice] = 'Personal address created successfully'
      redirect_to :controller => '/home', :action => :index and return
    else
      @address = @person.families.first.address
    end
    render :template => '/registration/people/new_address'
  end

  def edit_address
    @person = Person.find_by_id params[:id].to_i
    @address = @person.address
    if request.post?
      if @address.update_attributes params[:address]
        flash[:notice] = 'Personal address updated successfully'
        redirect_to :controller => '/home', :action => :index and return
      end
    end
    render :template => '/registration/people/edit_address'
  end

  private

  def action_authorized?
    if @user.person.id == params[:id].to_i or @user.person.is_a_parent_of?(params[:id].to_i)
      return true
    else
      flash[:notice] = "Access to requested personal data not authorized"
      redirect_to :controller => '/home', :action => :index and return false
    end
  end
end
