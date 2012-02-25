class Activity::TrackEventsController < ApplicationController
  
  def index
    @active_grade_classes = SchoolClass.find_all_active_grade_classes
    @active_grade_classes.sort! { |x, y| x.grade_id <=> y.grade_id }
  end
end
