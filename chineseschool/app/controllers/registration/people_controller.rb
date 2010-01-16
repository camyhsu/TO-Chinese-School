class Registration::PeopleController < ApplicationController

  def index
    @people = Person.find(:all)
  end

  def links_to_families
    
  end
  
end
