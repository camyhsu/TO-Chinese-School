class Address < ActiveRecord::Base

  def street_address
    "#{street}, #{city}, #{state} #{zipcode}"
  end
end
