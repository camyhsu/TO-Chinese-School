require 'spec_helper'

describe Role, 'performing authorization' do
  fixtures :roles
  
  before(:each) do
    @fake_controller_path = random_string 14
    @fake_action_name = random_string 7
    @role = Role.new
  end

  it 'should return true if the role is super user' do
    roles(:super_user).authorized?(@fake_controller_path, @fake_action_name).should be_true
  end

  it 'should return true if one of rights matches access request' do
    mock_not_authorized_right = Right.new
    mock_not_authorized_right.expects(:authorized?).with(@fake_controller_path, @fake_action_name).once.returns(false)
    @role.rights << mock_not_authorized_right
    mock_authorized_right = Right.new
    mock_authorized_right.expects(:authorized?).with(@fake_controller_path, @fake_action_name).once.returns(true)
    @role.rights << mock_authorized_right
    @role.authorized?(@fake_controller_path, @fake_action_name).should be_true
  end

  it 'should return false if all rights do not match access request' do
    mock_not_authorized_right = Right.new
    mock_not_authorized_right.expects(:authorized?).with(@fake_controller_path, @fake_action_name).once.returns(false)
    @role.rights << mock_not_authorized_right
    @role.authorized?(@fake_controller_path, @fake_action_name).should be_false
  end
end
