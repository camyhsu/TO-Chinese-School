class Registration::PeopleController < ApplicationController

  def index
    @people = Person.find(:all)
    render :layout => 'jquery_datatable'
  end

  def show
    @person = Person.find_by_id(params[:id].to_i)
  end

  def edit
    if request.post?
      @person = Person.find_by_id(params[:id].to_i)
      if @person.update_attributes(params[:person])
        flash[:notice] = 'Person updated successfully'
        redirect_to :action => :show, :id => @person.id
      end
    else
      @person = Person.find_by_id(params[:id].to_i)
    end
  end

  def find_families_for
    person = Person.find_by_id(params[:id].to_i)
    families = person.families
    redirect_to(:controller => 'registration/families', :action => 'show', :id => families[0].id) and return if families.size == 1
    redirect_to(:controller => 'registration/families', :action => 'show_list', :id => families.collect { |family| family.id })
  end
end
