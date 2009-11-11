require 'spec_helper'

describe Family do
  fixtures :people
  
  it 'should be able to save and read children association' do
    family = Family.new
    family.children.should == []
    family.children << people(:person_one)
    family.children << people(:person_two)
    family.save!
    
    found_family = Family.find_by_id(family.id)
    found_family.should have(2).children
    found_family.child_ids.should include(people(:person_one).id)
    found_family.child_ids.should include(people(:person_two).id)
  end
end