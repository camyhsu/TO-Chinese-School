require 'spec_helper'

describe Address, 'showing street address' do
  fixtures :addresses
  
  it 'should return formatted street address ' do
    expected_street_address = "#{addresses(:one).street}, #{addresses(:one).city}, #{addresses(:one).state} #{addresses(:one).zipcode}"
    addresses(:one).street_address.should == expected_street_address
  end
end
