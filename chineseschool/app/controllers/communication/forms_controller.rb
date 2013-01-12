class Communication::FormsController < ApplicationController

  def picture_taking_form
    @current_school_year = SchoolYear.current_school_year
    retrieve_sorted_class_lists
    prawnto :filename => 'picture_taking_form.pdf'
    render :layout => false
  end
end
