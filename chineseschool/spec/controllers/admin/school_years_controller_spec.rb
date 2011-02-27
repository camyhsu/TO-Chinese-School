require 'spec_helper'

describe Admin::SchoolYearsController, 'setting date if original in future' do
  before(:each) do
    stub_check_authentication_and_authorization_in @controller
    @tomorrow = Date.today + 1
    @yesterday = Date.today - 1
    @parameters = {}
    @parameters[:school_year] = {}
    @parameters[:id] = 3

    @fake_school_year = SchoolYear.new
    SchoolYear.expects(:find_by_id).with(3).once.returns(@fake_school_year)
  end

  it 'should set date to new value if original date is in the future' do
    @parameters[:school_year][:start_date] = @tomorrow.to_s
    @fake_school_year.start_date = Date.today
    
    post :edit, @parameters
    assigns[:school_year].start_date.should == @tomorrow
  end

  it 'should not set date to new value if original date is in the past' do
    @parameters[:school_year][:start_date] = @tomorrow.to_s
    @fake_school_year.start_date = @yesterday

    post :edit, @parameters
    assigns[:school_year].start_date.should == @yesterday
  end

  it 'should set date to new value if original date is nil' do
    @parameters[:school_year][:start_date] = @tomorrow.to_s

    post :edit, @parameters
    assigns[:school_year].start_date.should == @tomorrow
  end
end
