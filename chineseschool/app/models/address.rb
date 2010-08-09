class Address < ActiveRecord::Base

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
