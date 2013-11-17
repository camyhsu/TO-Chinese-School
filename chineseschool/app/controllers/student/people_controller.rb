class Student::PeopleController < ApplicationController

  before_filter :action_authorized?

  def edit
    @person = Person.find params[:id].to_i
    if request.post? || request.put?
      if @person.update_attributes params[:person]
        flash[:notice] = 'Person updated successfully'
        redirect_to controller: '/home'
        return
      end
    end
    render template: '/registration/people/edit'
  end

  def new_address
    @person = Person.find params[:id].to_i
    if request.post? || request.put?
      @address = Address.new params[:address]
      unless @address.valid?
        render template: '/registration/people/new_address'
        return
      end
      Person.transaction do
        @address.save!
        @person.address = @address
        @person.save!
      end
      flash[:notice] = 'Personal address created successfully'
      redirect_to controller: '/home'
      return
    else
      @address = @person.families.first.address
    end
    render template: '/registration/people/new_address'
  end

  def edit_address
    @person = Person.find params[:id].to_i
    @address = @person.address
    if request.post? || request.put?
      if @address.update_attributes params[:address]
        flash[:notice] = 'Personal address updated successfully'
        redirect_to controller: '/home'
        return
      end
    end
    render template: '/registration/people/edit_address'
  end

  private

  def action_authorized?
    if @user.person.id == params[:id].to_i or @user.person.is_a_parent_of?(params[:id].to_i)
      true
    else
      flash[:notice] = 'Access to requested personal data not authorized'
      redirect_to controller: '/home'
      false
    end
  end
end
