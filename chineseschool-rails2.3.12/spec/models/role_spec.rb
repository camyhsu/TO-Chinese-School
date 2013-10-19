require 'spec_helper'

describe Role do
  fixtures :roles

  before(:each) do
    @role = Role.new
  end

  it 'should be invalid without a name' do
    @role.should_not be_valid
    @role.name = random_string 8
    @role.should be_valid
  end

  it 'should be invalid with a name already taken' do
    @role.name = roles(:instructor).name
    @role.should_not be_valid
    @role.name = 'name_not_used_yet'
    @role.should be_valid
  end
end


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
