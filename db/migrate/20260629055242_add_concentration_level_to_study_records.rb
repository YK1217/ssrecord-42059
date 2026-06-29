class AddConcentrationLevelToStudyRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :study_records, :concentration_level, :integer, null: false, default: 0
  end
end
