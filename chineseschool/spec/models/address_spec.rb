require 'spec_helper'

describe Address do
  fixtures :addresses

  before(:each) do
    @address = addresses(:minimal)
  end
  
  it 'should be invalid without street' do
    @address.street = nil
    expect(@address).not_to be_valid
    @address.street = random_string 8
    expect(@address).to be_valid
  end

  it 'should be invalid without city' do
    @address.city = nil
    expect(@address).not_to be_valid
    @address.city = random_string 8
    expect(@address).to be_valid
  end

  it 'should be invalid without state' do
    @address.state = nil
    expect(@address).not_to be_valid
    @address.state = random_string 8
    expect(@address).to be_valid
  end

  it 'should be invalid without zipcode' do
    @address.zipcode = nil
    expect(@address).not_to be_valid
    @address.zipcode = '12345'  # zipcode must be numeric
    expect(@address).to be_valid
  end

  it 'should be invalid without home phone' do
    @address.home_phone = nil
    expect(@address).not_to be_valid
    @address.home_phone = '12345'
    expect(@address).to be_valid
  end

  it 'should be invalid given non-numeric zipcode' do
    @address.zipcode = 'abc'
    expect(@address).not_to be_valid
    @address.zipcode = '12345'
    expect(@address).to be_valid
  end

  it 'should be invalid given zipcode more than 5 digits' do
    @address.zipcode = '123456'
    expect(@address).not_to be_valid
    @address.zipcode = '12345'
    expect(@address).to be_valid
  end
end

describe Address, 'showing street address' do
  fixtures :addresses
  
  it 'should return formatted street address ' do
    expected_street_address = "#{addresses(:one).street}, #{addresses(:one).city}, #{addresses(:one).state} #{addresses(:one).zipcode}"
    expect(addresses(:one).street_address).to eq(expected_street_address)
  end
end

describe Address, 'cleaning and formatting phone number' do
  before(:each) do
    @address = Address.new
  end

  it 'should clean phone number by removing non-digit characters' do
    expect(Address.clean_phone_number('a12d 3c 4ss5')).to eq('12345')
  end

  it 'should return nil for cleaning phone number if given nil' do
    expect(Address.clean_phone_number(nil)).to be_nil
  end

  it 'should format phone number the format (xxx) xxx-xxxx' do
    expect(@address.format_phone_number('8051234567')).to eq('(805) 123-4567')
  end

  it 'should return empty string for formatting phone number if given nil' do
    expect(@address.format_phone_number(nil)).to eq('')
  end

  it 'should return empty string for formatting phone number if given empty string' do
    expect(@address.format_phone_number('')).to eq('')
  end

  it 'should clean and format phone number when setting and getting home phone' do
    @address.home_phone = 'a12d 3c 4ss5 d67k 8'
    expect(@address.home_phone).to eq('(123) 456-78')
  end

  it 'should clean and format phone number when setting and getting cell phone' do
    @address.cell_phone = 'a12d 3c 4ss5 d67k 8'
    expect(@address.cell_phone).to eq('(123) 456-78')
  end
end

describe Address, 'checking phone numbers' do
  before(:each) do
    @address = Address.new
    @address.home_phone = '098.765.4321'
    @address.cell_phone = '123.456.7890'
  end

  it 'should return true if cell phone number matches after cleaning' do
    expect(@address.phone_number_correct?('(123) 456-7890')).to be true
  end

  it 'should return true if home phone number matches after cleaning' do
    expect(@address.phone_number_correct?('(098) 765-4321')).to be true
  end

  it 'should return false if both home and cell phone number do not match after cleaning' do
    expect(@address.phone_number_correct?('(805) 555-4321')).to be false
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
    expect(@address.email_and_phone_number_correct?(random_string(7), '')).to be false
  end

  it 'should return false if phone number does not match either home phone or cell phone' do
    expect(@address.email_and_phone_number_correct?(@fake_email, '(805) 555-1234')).to be false
  end

  it 'should return true if email matches and home phone matches' do
    expect(@address.email_and_phone_number_correct?(@fake_email, '(098) 765-4321')).to be true
  end

  it 'should return true if email matches and home phone matches' do
    expect(@address.email_and_phone_number_correct?(@fake_email, '(123) 456-7890')).to be true
  end
end
