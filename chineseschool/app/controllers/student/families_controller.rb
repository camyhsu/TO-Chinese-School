class Student::FamiliesController < ApplicationController

  before_filter :action_authorized?

  def edit_address
    @family = Family.find params[:id].to_i
    @address = @family.address
    if request.post? || request.put?
      if @address.update_attributes params[:address]
        flash[:notice] = 'Family address updated successfully'
        redirect_to controller: '/home'
        return
      end
    end
    render template: '/registration/families/edit_address'
  end

  def add_parent
    if request.post? || request.put?
      @parent_two = Person.new params[:person]
      if @parent_two.valid?
        family = Family.find params[:id].to_i
        family.parent_two = @parent_two
        if family.save
          flash[:notice] = 'New parent added successfully'
          redirect_to controller: '/home'
          return
        end
      end
    else
      @parent_two = Person.new
    end
    render template: '/registration/families/add_parent'
  end

  def add_child
    if request.post? || request.put?
      @child = Person.new params[:person]
      @child.mark_as_new_child
      if @child.valid?
        family = Family.find params[:id].to_i
        family.children << @child
        if family.save
          flash[:notice] = 'New child added successfully'
          redirect_to controller: '/home'
          return
        end
      end
    else
      @child = Person.new
    end
    render template: '/registration/families/add_child'
  end

  private

  def action_authorized?
    family = Family.find params[:id].to_i
    if family.parent_one_is?(@user.person) || family.parent_two_is?(@user.person)
      true
    else
      flash[:notice] = 'Access to requested family data not authorized'
      redirect_to controller: '/home'
      false
    end
  end
end
