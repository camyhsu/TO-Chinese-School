require 'spec_helper'

describe Address do
  fixtures :addresses

  before(:each) do
    @address = addresses(:minimal)
  end
  
  it 'should be invalid without street' do
    @address.street = nil
    @address.should_not be_valid
    @address.street = random_string 8
    @address.should be_valid
  end

  it 'should be invalid without city' do
    @address.city = nil
    @address.should_not be_valid
    @address.city = random_string 8
    @address.should be_valid
  end

  it 'should be invalid without state' do
    @address.state = nil
    @address.should_not be_valid
    @address.state = random_string 8
    @address.should be_valid
  end

  it 'should be invalid without zipcode' do
    @address.zipcode = nil
    @address.should_not be_valid
    @address.zipcode = '12345'  # zipcode must be numeric
    @address.should be_valid
  end

  it 'should be invalid without home phone' do
    @address.home_phone = nil
    @address.should_not be_valid
    @address.home_phone = '12345'
    @address.should be_valid
  end

  it 'should be invalid given non-numeric zipcode' do
    @address.zipcode = 'abc'
    @address.should_not be_valid
    @address.zipcode = '12345'
    @address.should be_valid
  end

  it 'should be invalid given zipcode more than 5 digits' do
    @address.zipcode = '123456'
    @address.should_not be_valid
    @address.zipcode = '12345'
    @address.should be_valid
  end
end

describe Address, 'showing street address' do
  fixtures :addresses
  
  it 'should return formatted street address ' do
    expected_street_address = "#{addresses(:one).street}, #{addresses(:one).city}, #{addresses(:one).state} #{addresses(:one).zipcode}"
    addresses(:one).street_address.should == expected_street_address
  end
end

describe Address, 'cleaning and formating phone number' do
  before(:each) do
    @address = Address.new
  end

  it 'should clean phone number by removing non-digit characters' do
    @address.clean_phone_number('a12d 3c 4ss5').should == '12345'
  end

  it 'should return nil for cleaning phone number if given nil' do
    @address.clean_phone_number(nil).should be_nil
  end

  it 'should format phone number the format (xxx) xxx-xxxx' do
    @address.format_phone_number('8051234567').should == '(805) 123-4567'
  end

  it 'should return empty string for formating phone number if given nil' do
    @address.format_phone_number(nil).should == ''
  end

  it 'should return empty string for formating phone number if given empty string' do
    @address.format_phone_number('').should == ''
  end

  it 'should clean and format phone number when setting and getting home phone' do
    @address.home_phone = 'a12d 3c 4ss5 d67k 8'
    @address.home_phone.should == '(123) 456-78'
  end

  it 'should clean and format phone number when setting and getting cell phone' do
    @address.cell_phone = 'a12d 3c 4ss5 d67k 8'
    @address.cell_phone.should == '(123) 456-78'
  end
end

describe Address, 'checking phone numbers' do
  before(:each) do
    @address = Address.new
    @address.home_phone = '098.765.4321'
    @address.cell_phone = '123.456.7890'
  end

  it 'should return true if cell phone number matches after cleaning' do
    @address.phone_number_correct?('(123) 456-7890').should be_true
  end

  it 'should return true if home phone number matches after cleaning' do
    @address.phone_number_correct?('(098) 765-4321').should be_true
  end

  it 'should return false if both home and cell phone number do not match after cleaning' do
    @address.phone_number_correct?('(805) 555-4321').should be_false
  end
end

describe Address, 'checking email and phone numbers' do
  before(:each) do
    @fake_email = random_string 8
    @address = Address.new
    @address.email = @fake_email
    @address.home_phone = '098.765.4321'
    @address.cell_phone = '123.456.7890'
  end

  it 'should return false if email does not match' do
    @address.email_and_phone_number_correct?(random_string(7), '').should be_false
  end

  it 'should return false if phone number does not match either home phone or cell phone' do
    @address.email_and_phone_number_correct?(@fake_email, '(805) 555-1234').should be_false
  end

  it 'should return true if email matches and home phone matches' do
    @address.email_and_phone_number_correct?(@fake_email, '(098) 765-4321').should be_true
  end

  it 'should return true if email matches and home phone matches' do
    @address.email_and_phone_number_correct?(@fake_email, '(123) 456-7890').should be_true
  end
end
