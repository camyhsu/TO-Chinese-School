class TrackEventAgeGroup

  def initialize(min_age, max_age)
    @min_age = min_age
    @max_age = max_age
  end

  def contains_heat_by_upper_bound?(track_event_heat)
    return true if @max_age.nil?
    track_event_heat.max_student_school_age <= @max_age
  end
end