# テストログイン用ユーザーを作成する
test_user = User.find_or_initialize_by(email: "test@example.ne.jp")
test_user.name = "Test_User"
test_user.password = ENV["TEST_PASSWORD"]
test_user.password_confirmation = test_user.password

if test_user.save
  puts "テストログイン用ユーザーを作成しました"
  puts "email: test@example.ne.jp"
  puts "name: Test_User"
else
  puts "テストログイン用ユーザーの作成に失敗しました"
  puts test_user.errors.full_messages
  exit
end

# 作っておきたい記録の数
target_count = 11

# nil化する確率
nil_rate = 0.5

needed_count = target_count - test_user.study_records.size

if needed_count > 0
  puts "----------------------------------------"
  puts "テストログイン用ユーザーに学習記録を #{needed_count}個作ります"

  current_date = Date.yesterday
  created_count = 0

  while created_count < needed_count do
    unless test_user.study_records.where(study_date: current_date).exists?
      new_record = FactoryBot.build(:study_record, user: test_user)

      new_record.start_time = new_record.start_time.change(
        year: current_date.year,
        month: current_date.month,
        day: current_date.day
      )

      # end_timeが登録済みの学習記録が3個以上あれば、一定確率で終了時刻を未入力にする
      if test_user.study_records.where.not(end_time: nil).count >= 3 && rand < nil_rate
        new_record.end_clock = nil
      end

      # study_memoが登録済みの学習記録が3個以上あれば、一定確率で学習メモを未入力にする
      if test_user.study_records.where.not(study_memo: nil).count >= 3 && rand < nil_rate
        new_record.study_memo = nil
      end

      new_record.save!

      puts "\nstart_time: #{new_record.start_time}"
      puts "end_time: #{new_record.end_time.inspect}"
      puts "study_memo: #{new_record.study_memo.inspect}"

      created_count += 1
    end

    current_date -= 2
    break if current_date < Date.current - 1.year
  end

  puts "\n学習記録の作成を終了しました"
end

needed_count = target_count - test_user.sleep_records.size

if needed_count > 0
  puts "----------------------------------------"
  puts "テストログイン用ユーザーに睡眠記録を #{needed_count}個作ります"

  current_date = Date.yesterday
  created_count = 0

  while created_count < needed_count do
    unless test_user.sleep_records.where(sleep_date: current_date).exists?
      new_record = FactoryBot.build(:sleep_record, user: test_user)

      base_time = Time.zone.local(
        current_date.year,
        current_date.month,
        current_date.day,
        22,
        0
      )

      new_record.start_time = base_time + rand(0..4 * 60).minutes

      # end_timeが登録済みの睡眠記録が3個以上あれば、一定確率で終了時刻を未入力にする
      if test_user.sleep_records.where.not(end_time: nil).count >= 3 && rand < nil_rate
        new_record.end_clock = nil
      end

      new_record.save!

      puts "\nstart_time: #{new_record.start_time}"
      puts "end_time: #{new_record.end_time.inspect}"

      created_count += 1
    end

    current_date -= 2
    break if current_date < Date.current - 1.year
  end

  puts "\n睡眠記録の作成を終了しました"
end
