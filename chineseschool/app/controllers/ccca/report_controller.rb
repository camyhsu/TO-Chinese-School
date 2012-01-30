class Ccca::ReportController < ApplicationController
  
  def active_family_home_phone_numbers
    @home_phone_numbers = StudentStatusFlag.find_all_registered_flags.collect do |registered_flag|
      families = registered_flag.student.find_families_as_child
      if families.empty?
        families = registered_flag.student.find_families_as_parent
      end
      if families.empty?
        nil
      else
        families[0].address.home_phone
      end
    end.uniq.compact
    headers["Content-Type"] = 'text/csv'
    headers["Content-Disposition"] = 'attachment; filename="active_family_home_phone_numbers.csv"'
    render :layout => false
  end
end
