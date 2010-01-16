require 'spec_helper'

describe Registration::FamiliesController do

  #Delete these examples and add some real ones
  it "should use Registration::FamiliesController" do
    controller.should be_an_instance_of(Registration::FamiliesController)
  end


  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
  end
end
