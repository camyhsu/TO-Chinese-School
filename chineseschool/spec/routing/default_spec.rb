require 'spec_helper'

describe ActionController::Routing::Routes, 'by default' do
  it 'should strip leading chineseschool path component when routing' do
    params_from(:get, '/chineseschool/admin/grades').should == { :controller => 'admin/grades', :action => 'index' }
    params_from(:get, '/chineseschool/admin/grades/show/3').should == { :controller => 'admin/grades', :action => 'show', :id => '3' }
  end
end