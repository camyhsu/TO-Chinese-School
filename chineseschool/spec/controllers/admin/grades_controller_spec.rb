require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::GradesController, 'displaying index' do
  before(:each) do
    @fake_grades = []
    Grade.stubs(:find).with(:all).returns(@fake_grades)
  end

  it 'should find all grades' do
    Grade.expects(:find).with(:all).once.returns(@fake_grades)
    get :index
  end

  it 'should assign grades found' do
    get :index
    assigns[:grades].should equal(@fake_grades)
  end

  it 'should be success' do
    get :index
    response.should be_success
  end
  
  it 'should render index template' do
    get :index
    response.should render_template('admin/grades/index.html.erb')
  end

  it 'should respond to routes' do
    params_from(:get, '/chineseschool/admin/grades').should == { :controller => 'admin/grades', :action => 'index' }
  end
end
