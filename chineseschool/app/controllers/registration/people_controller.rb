class Registration::PeopleController < ApplicationController

  def index
    @people = Person.find(:all)
  end

  def show
    @person = Person.find_by_id(params[:id].to_i)
  end

  def find_families_for
    person = Person.find_by_id(params[:id].to_i)
    families = person.families
    redirect_to(:controller => 'registration/families', :action => 'show', :id => families[0].id) and return if families.size == 1
    redirect_to(:controller => 'registration/families', :action => 'show_list', :id => families.collect { |family| family.id })
  end
end
