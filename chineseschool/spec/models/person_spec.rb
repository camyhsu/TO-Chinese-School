require 'spec_helper'

describe Person do
  fixtures :people, :families, :families_children

  it 'should find the family while being the parent_one of that family' do
    person_one_families = people(:person_one).families
    person_one_families.should have(1).family
    person_one_families.should include(families(:family_one))
  end

  it 'should find the family while being the parent_two of that family' do
    person_two_families = people(:person_two).families
    person_two_families.should have(1).family
    person_two_families.should include(families(:family_two))
  end

  it 'should find the family while being a child in that family' do
    person_three_families = people(:person_three).families
    person_three_families.should have(1).family
    person_three_families.should include(families(:family_one))
  end
end
