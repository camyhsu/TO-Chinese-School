require 'spec_helper'

describe Person, 'showing name' do
  fixtures :people

  it 'should return one blank space in parentheses if no name exists' do
    Person.new.name.should == '( )'
  end

  it 'should return English first name in parentheses if only english first name exists' do
    people(:person_with_only_first_name).name.should == "(#{people(:person_with_only_first_name).english_first_name} )"
  end
  
  it 'should return English last name in parentheses if only english last name exists' do
    people(:person_two).name.should == "( #{people(:person_two).english_last_name})"
  end

  it 'should return English name in parentheses if both english first and last name exist but not chinese name' do
    people(:person_three).name.should == "(#{people(:person_three).english_first_name} #{people(:person_three).english_last_name})"
  end

  it 'should return Chinese name followed by English name in parenthese' do
    people(:person_with_chinese_name).name.should == "#{people(:person_with_chinese_name).chinese_name}(#{people(:person_with_chinese_name).english_first_name} #{people(:person_with_chinese_name).english_last_name})"
  end
end

describe Person, 'finding families' do
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
