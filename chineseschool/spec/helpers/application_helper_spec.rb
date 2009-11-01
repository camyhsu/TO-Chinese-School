require 'spec_helper'

describe ApplicationHelper, 'converting boolean flag to yes / no' do
  it 'should return Yes if the flag is true' do
    helper.convert_to_yes_no(true).should == 'Yes'
  end

  it 'should return No if the flag is false' do
    helper.convert_to_yes_no(false).should == 'No'
  end
end
