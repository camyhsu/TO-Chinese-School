require 'spec_helper'

describe SchoolYear do
  before(:each) do
    @school_year = create_fake_school_year
  end

  it 'should validate that start date is not later then end date' do
    @school_year.start_date = Date.today
    @school_year.end_date = Date.today
    @school_year.valid?.should be_true

    @school_year.start_date = Date.tomorrow
    @school_year.valid?.should be_false
    @school_year.errors[:start_date].should == " can not be later than End date"
  end
end

describe SchoolYear, 'finding current school year' do
  after(:each) do
    teardown_school_years
  end
  
  it 'should find the school year today falls into if there is one' do
    setup_current_school_year
    SchoolYear.current_school_year.should == @current_school_year
  end

  it 'should find the first school year starting in the near future if today does not fall into one' do
    SchoolYear.current_school_year.should be_nil
    setup_two_school_years_starting_in_near_future
    SchoolYear.current_school_year.should == @first_school_year_starting_in_near_future
  end
end

describe SchoolYear, 'finding next school year' do
  after(:each) do
    teardown_school_years
  end

  it 'should find the first school year starting in the near future' do
    setup_current_school_year
    setup_two_school_years_starting_in_near_future
    SchoolYear.next_school_year.should == @first_school_year_starting_in_near_future
  end

  it 'should find the following school year if current school year is the one starting in the near future' do
    setup_two_school_years_starting_in_near_future
    SchoolYear.next_school_year.should == @second_school_year_starting_in_near_future
  end

  it 'should return nil if next school year could not be found' do
    setup_current_school_year
    SchoolYear.next_school_year.should be_nil
  end

  it 'should return nil if next school year could not be found when current school year is the one starting in the near future' do
    setup_one_school_years_starting_in_near_future
    SchoolYear.next_school_year.should be_nil
  end
end

describe SchoolYear, 'finding current and future school years' do
  it 'should find current and future years' do
    fake_school_years = [SchoolYear.new, SchoolYear.new]
    SchoolYear.expects(:all).with(:conditions => ["end_date >= ?", Date.today], :order => 'start_date ASC').once.returns(fake_school_years)
    SchoolYear.find_current_and_future_school_years.should == fake_school_years
  end
end

def create_fake_school_year
  school_year = SchoolYear.new
  school_year.name = random_string
  school_year.start_date = Date.today
  school_year.end_date = Date.today
  school_year.age_cutoff_month = 12
  school_year.registration_start_date = Date.today
  school_year.pre_registration_end_date = Date.today
  school_year.registration_75_percent_date = Date.today
  school_year.registration_50_percent_date = Date.today
  school_year.registration_end_date = Date.today
  school_year.refund_75_percent_date = Date.today
  school_year.refund_50_percent_date = Date.today
  school_year.refund_25_percent_date = Date.today
  school_year.refund_end_date = Date.today
  school_year
end

def setup_current_school_year
  @current_school_year = create_fake_school_year
  @current_school_year.start_date = Date.today
  @current_school_year.end_date = Date.today
  @current_school_year.save!
end

def setup_one_school_years_starting_in_near_future
  @first_school_year_starting_in_near_future = create_fake_school_year
  @first_school_year_starting_in_near_future.start_date = Date.today + 1
  @first_school_year_starting_in_near_future.end_date = Date.today + 10
  @first_school_year_starting_in_near_future.save!
end

def setup_two_school_years_starting_in_near_future
  setup_one_school_years_starting_in_near_future
  
  @second_school_year_starting_in_near_future = create_fake_school_year
  @second_school_year_starting_in_near_future.start_date = Date.today + 2
  @second_school_year_starting_in_near_future.end_date = Date.today + 10
  @second_school_year_starting_in_near_future.save!
end

def teardown_school_years
  @current_school_year.delete unless @current_school_year.nil?
  @first_school_year_starting_in_near_future.delete unless @first_school_year_starting_in_near_future.nil?
  @second_school_year_starting_in_near_future.delete unless @second_school_year_starting_in_near_future.nil?
end
