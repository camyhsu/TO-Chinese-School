class Registration::PeopleController < ApplicationController

  def index
    @people = Person.find(:all)
  end

  def find_families_for
    person = Person.find_by_id(params[:id].to_i)
    families = person.families
    redirect_to(:controller => 'registration/families', :action => 'show', :id => families[0].id) if families.size == 1
  end
  
end
