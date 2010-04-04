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

describe Family, 'showing children names' do

  it 'should return empty string if no children exists' do
    Family.new.children_names.should be_empty
  end

  it 'should return child name if one child exists' do
    fake_child_name = random_string
    child = Person.new
    child.expects(:name).once.returns(fake_child_name)
    family = Family.new
    family.children << child

    family.children_names.should == fake_child_name
  end

  it 'should return children names delimited by comma and one space if more than one child exist' do
    fake_child_name_one = random_string
    child_one = Person.new
    child_one.expects(:name).once.returns(fake_child_name_one)
    fake_child_name_two = random_string
    child_two = Person.new
    child_two.expects(:name).once.returns(fake_child_name_two)
    family = Family.new
    family.children << child_one
    family.children << child_two

    expected_children_name = "#{fake_child_name_one}, #{fake_child_name_two}"
    family.children_names.should == expected_children_name
  end
end
