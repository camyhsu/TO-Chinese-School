class Address < ActiveRecord::Base
  
  has_one :person
  has_one :family
  
  validates :street, :city, :state, :zipcode, :home_phone, :email, presence: true

  validates :zipcode, numericality: {only_integer: true, less_than: 100000}


  def home_phone
    format_phone_number(read_attribute(:home_phone))
  end

  def home_phone=(phone)
    write_attribute(:home_phone, Address.clean_phone_number(phone))
  end

  def cell_phone
    format_phone_number(read_attribute(:cell_phone))
  end

  def cell_phone=(phone)
    write_attribute(:cell_phone, Address.clean_phone_number(phone))
  end


  def street_address
    "#{street}, #{city}, #{state} #{zipcode}"
  end
  
  def email_and_phone_number_correct?(email_to_check, phone_number_to_check)
    (self.email == email_to_check) and phone_number_correct?(phone_number_to_check)
  end

  def phone_number_correct?(phone_number_to_check)
    cleaned_phone_number = Address.clean_phone_number phone_number_to_check
    logger.info "Cleaning phone number #{phone_number_to_check} => #{cleaned_phone_number}"
    (read_attribute(:home_phone) == cleaned_phone_number) or (read_attribute(:cell_phone) == cleaned_phone_number)
  end

  def format_phone_number(phone_number)
    return '' if phone_number.blank?
    "(#{phone_number[0..2]}) #{phone_number[3..5]}-#{phone_number[6..-1]}"
  end

  def self.clean_phone_number(phone_number_to_clean)
    return nil if phone_number_to_clean.nil?
    phone_number_to_clean.gsub /\D/, ''
  end

  def self.search_by_phone(phone_number)
    cleaned_phone_number = Address.clean_phone_number phone_number
    Address.all :conditions => ['home_phone = ? OR cell_phone = ?', cleaned_phone_number, cleaned_phone_number]
  end
end
