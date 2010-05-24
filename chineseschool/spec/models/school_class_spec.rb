require 'spec_helper'

describe SchoolClass do
  it 'should have an instructor assignment history' do
    SchoolClass.new.instructor_assignment_history.should_not be_nil
  end
end
