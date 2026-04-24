class CreateStudyRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :study_records do |t|

      t.timestamps
    end
  end
end
