class TrackEventAgeGroup

  def initialize(min_age, max_age)
    @min_age = min_age
    @max_age = max_age
  end

  def name
    if @max_age.nil?
      "Age Group #{@min_age} and Over"
    else
      "Age Group #{@min_age} - #{@max_age}"
    end
  end

  def contains_heat_by_upper_bound?(track_event_heat)
    return true if @max_age.nil?
    if track_event_heat.track_event_program.individual_program?
      track_event_heat.max_student_school_age <= @max_age
    else
      track_event_heat.max_team_age <= @max_age
    end
  end

  def contains_student?(student)
    school_age = student.school_age_for(SchoolYear.current_school_year)
    return false if school_age < @min_age
    return true if @max_age.nil?
    return false if school_age > @max_age
    true
  end

  def contains_team?(team)
    team_age = team.team_age
    return false if team_age < @min_age
    return true if @max_age.nil?
    return false if team_age > @max_age
    true
  end
end