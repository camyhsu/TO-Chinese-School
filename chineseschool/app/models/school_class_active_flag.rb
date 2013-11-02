class SchoolClassActiveFlag < ActiveRecord::Base
  
  belongs_to :school_class
  belongs_to :school_year
  
end
