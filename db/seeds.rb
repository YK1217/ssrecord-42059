# テストログイン用ユーザーを作成する
test_user = User.find_or_initialize_by(email: "test@example.ne.jp")
test_user.name = "Test_User"
test_user.password = ENV["TEST_PASSWORD"]
test_user.password_confirmation = test_user.password
test_user.save!

puts "テストログイン用ユーザーを作成しました"
puts "email: test@example.ne.jp"
puts "name: Test_User"

  if test_user.nil?
    puts "テストログイン用ユーザーの作成に失敗しました"
    exit
  end

  # 作っておきたい記録の数
  target_count = 11

  needed_count = target_count - test_user.study_records.size

if needed_count > 0
  puts "----------------------------------------"
  puts "テストログイン用ユーザーに学習記録を #{needed_count}個作ります"

  current_date = Date.yesterday

  while test_user.study_records.size < target_count do
    unless test_user.study_records.where(study_date: current_date).exists?
      new_record = FactoryBot.build(:study_record, user: test_user)
      new_record.start_time = new_record.start_time.change(year: current_date.year, month: current_date.month, day: current_date.day)
      new_record.save!
      puts "\nstart_time: #{new_record.start_time}"
      puts "end_time: #{new_record.end_time}"
      puts "study_memo: #{new_record.study_memo}"
    end
    current_date -= 2

    if current_date < Date.current - 1.year
      break
    end
  end

  puts "\n学習記録の作成を終了しました"

end
