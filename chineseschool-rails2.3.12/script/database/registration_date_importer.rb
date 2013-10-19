
school_year_2008 = SchoolYear.find_by_name '2008-2009'
school_year_2008.age_cutoff_month = 12
school_year_2008.registration_start_date = Date.parse '2008-06-01'
school_year_2008.registration_75_percent_date = Date.parse '2008-11-02'
school_year_2008.registration_50_percent_date = Date.parse '2009-01-31'
school_year_2008.registration_end_date = Date.parse '2009-01-31'
school_year_2008.refund_75_percent_date = Date.parse '2008-09-20'
school_year_2008.refund_50_percent_date = Date.parse '2008-11-01'
school_year_2008.refund_25_percent_date = Date.parse '2009-01-24'
school_year_2008.refund_end_date = Date.parse '2009-03-28'
school_year_2008.save!

school_year_2009 = SchoolYear.find_by_name '2009-2010'
school_year_2009.age_cutoff_month = 12
school_year_2009.registration_start_date = Date.parse '2009-06-01'
school_year_2009.registration_75_percent_date = Date.parse '2009-10-31'
school_year_2009.registration_50_percent_date = Date.parse '2010-01-23'
school_year_2009.registration_end_date = Date.parse '2010-01-23'
school_year_2009.refund_75_percent_date = Date.parse '2009-09-20'
school_year_2009.refund_50_percent_date = Date.parse '2009-11-15'
school_year_2009.refund_25_percent_date = Date.parse '2010-01-17'
school_year_2009.refund_end_date = Date.parse '2010-02-28'
school_year_2009.save!

school_year_2010 = SchoolYear.find_by_name '2010-2011'
school_year_2010.age_cutoff_month = 12
school_year_2010.registration_start_date = Date.parse '2010-06-07'
school_year_2010.registration_75_percent_date = Date.parse '2010-10-31'
school_year_2010.registration_50_percent_date = Date.parse '2011-01-29'
school_year_2010.registration_end_date = Date.parse '2011-01-29'
school_year_2010.refund_75_percent_date = Date.parse '2010-09-18'
school_year_2010.refund_50_percent_date = Date.parse '2010-10-30'
school_year_2010.refund_25_percent_date = Date.parse '2011-01-15'
school_year_2010.refund_end_date = Date.parse '2011-03-12'
school_year_2010.save!
