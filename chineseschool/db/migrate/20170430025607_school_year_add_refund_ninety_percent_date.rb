class SchoolYearAddRefundNinetyPercentDate < ActiveRecord::Migration
  def change
    change_table :school_years do |t|
      t.date :refund_90_percent_date
    end
  end
end
