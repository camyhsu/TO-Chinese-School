require File.expand_path(File.dirname(__FILE__) + '/grade_importer')

class StaticDataImporter

  def initialize(data_base_dir)
    @data_base_dir = data_base_dir
  end

  def import
    GradeImporter.new("#{@data_base_dir}/grades.csv").import
  end
end
