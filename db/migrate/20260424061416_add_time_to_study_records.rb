class AddTimeToStudyRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :study_records, :study_time, :integer
  end
end
