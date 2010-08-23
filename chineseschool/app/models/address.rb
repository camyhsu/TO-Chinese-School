class Address < ActiveRecord::Base

  validates_presence_of :street, :city, :state, :zipcode, :home_phone

  validates_numericality_of :zipcode, :only_integer => true, :less_than => 100000
  validates_numericality_of :home_phone, :only_integer => true
  validates_numericality_of :cell_phone, :only_integer => true, :allow_blank => true


  def home_phone=(phone)
    write_attribute(:home_phone, clean_number(phone))
  end

  def cell_phone=(phone)
    write_attribute(:cell_phone, clean_number(phone))
  end


  def street_address
    "#{street}, #{city}, #{state} #{zipcode}"
  end
  
  def email_and_phone_number_correct?(email_to_check, phone_number_to_check)
    cleaned_phone_number = clean_number phone_number_to_check
    puts "Cleaning phone number #{phone_number_to_check} => #{cleaned_phone_number}"
    (self.email == email_to_check) and ((self.home_phone == cleaned_phone_number) or (self.cell_phone == cleaned_phone_number))
  end

  def clean_number(phone_number_to_clean)
    phone_number_to_clean.gsub /\D/, ''
  end
end
