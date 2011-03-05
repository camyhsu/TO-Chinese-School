require 'spec_helper'

describe SchoolYear do
  before(:each) do
    @school_year = SchoolYear.new
    @school_year.name = random_string
    @school_year.start_date = Date.today
    @school_year.end_date = Date.today
    @school_year.age_cutoff_month = 12
    @school_year.registration_start_date = Date.today
    @school_year.registration_75_percent_date = Date.today
    @school_year.registration_50_percent_date = Date.today
    @school_year.registration_end_date = Date.today
    @school_year.refund_75_percent_date = Date.today
    @school_year.refund_50_percent_date = Date.today
    @school_year.refund_25_percent_date = Date.today
    @school_year.refund_end_date = Date.today
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
