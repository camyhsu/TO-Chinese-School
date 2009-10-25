require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Right, 'performing authorization' do
  before(:each) do
    @fake_controller_path = random_string 14
    @fake_action_name = random_string 7
    @right = Right.new
  end
  
  it 'should return true if the right matches access request' do
    @right.controller = @fake_controller_path
    @right.action = @fake_action_name
    @right.authorized?(@fake_controller_path, @fake_action_name).should be_true
  end
  
  it 'should return false if the right does not match controller_path' do
    @right.action = @fake_action_name
    @right.authorized?(@fake_controller_path, @fake_action_name).should be_false
  end
  
  it 'should return false if the right does not match action_name' do
    @right.controller = @fake_controller_path
    @right.authorized?(@fake_controller_path, @fake_action_name).should be_false
  end
end
