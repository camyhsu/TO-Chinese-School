require 'spec_helper'

describe InstructorAssignmentHistory do
  it 'should be created with the associated school class id' do
    lambda { InstructorAssignmentHistory.new }.should raise_error(ArgumentError, 'wrong number of arguments (0 for 1)')
  end
end
