class Registration::PeopleController < ApplicationController

  def index
    @people = Person.find(:all)
  end
  
end
