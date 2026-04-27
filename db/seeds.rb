# テストログイン用ユーザーを作成する
test_user = User.find_or_initialize_by(email: "test@example.ne.jp")
test_user.name = "Test_User"
test_user.password = ENV["TEST_PASSWORD"]
test_user.password_confirmation = test_user.password
test_user.save!

puts "テストログイン用ユーザーを作成しました"
puts "email: test@example.ne.jp"
puts "name: Test_User"

  needed_count = 3 - test_user.study_records.size

if needed_count > 0
  puts "----------------------------------------"
  puts "テストログイン用ユーザーに学習記録を #{needed_count}個作ります"

  new_records = FactoryBot.create_list(:study_record, needed_count, user: test_user)

  new_records.each do |new_record|
    puts "\nstart_time: #{new_record.start_time}"
    puts "end_time: #{new_record.end_time}"
    puts "study_memo: #{new_record.study_memo}"
  end

  puts "\n学習記録を #{needed_count}個作成しました"

end
