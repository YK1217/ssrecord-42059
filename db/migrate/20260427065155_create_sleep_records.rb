class CreateSleepRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :sleep_records do |t|
      t.datetime  :start_time, null:false
      t.datetime  :end_time,  default: nil
      t.date  :sleep_date,  null:false
      t.references :user,  null:false, foreign_key: true

      t.timestamps
    end

    add_index :sleep_records, [:user_id, :sleep_date], unique: true
  end
end
