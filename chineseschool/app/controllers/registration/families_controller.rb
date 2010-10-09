class Registration::FamiliesController < ApplicationController

  def show
    @family = Family.find_by_id params[:id].to_i
  end

  def new
    if request.post?
      @address = Address.new params[:address]
      @parent_one = Person.new params[:parent_one]
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

  def edit_address
    @family = Family.find_by_id params[:id].to_i
    @address = @family.address
    if request.post?
      if @address.update_attributes params[:address]
        flash[:notice] = 'Family address updated successfully'
        redirect_to :action => :show, :id => @family.id
      end
    end
  end

  def add_parent
    if request.post?
      @parent_two = Person.new params[:parent_two]
      return unless @parent_two.valid?
      family = Family.find_by_id params[:id].to_i
      family.parent_two = @parent_two
      if family.save
        flash[:notice] = 'New parent added successfully'
        redirect_to :action => :show, :id => family.id
      end
    else
      @parent_two = Person.new
    end
  end
  
  def add_child
    if request.post?
      @child = Person.new params[:child]
      return unless @child.valid?
      family = Family.find_by_id params[:id].to_i
      family.children << @child
      if family.save
        flash[:notice] = 'New child added successfully'
        redirect_to :action => :show, :id => family.id
      end
    else
      @child = Person.new
    end
  end
end
