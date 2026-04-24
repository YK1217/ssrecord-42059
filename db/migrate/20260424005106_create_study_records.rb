class CreateStudyRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :study_records do |t|
      t.datetime  :start_time, null:false
      t.datetime  :end_time,  default: nil
      t.date  :study_date,  null:false
      t.string  :study_memo,  default: nil
      t.references  :user,  null:false, foreign_key: true

      t.timestamps
    end
  end
end
