require File.expand_path(File.dirname(__FILE__) + '/grade_importer')
require File.expand_path(File.dirname(__FILE__) + '/school_year_importer')

class StaticDataImporter

  def initialize(data_base_dir)
    @data_base_dir = data_base_dir
  end

  def import
    GradeImporter.new("#{@data_base_dir}/grades.csv").import
    #SchoolYearImporter.new("#{@data_base_dir}/school_years.csv").import
  end
end
