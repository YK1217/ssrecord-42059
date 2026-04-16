# テストログイン用ユーザーを作成する
test_user = User.find_or_initialize_by(email: "test@example.ne.jp")
test_user.name = "Test_User"
test_user.password = ENV["TEST_PASSWORD"]
test_user.password_confirmation = test_user.password
test_user.save!

puts "テストログイン用ユーザーを作成しました"
puts "email: test@example.ne.jp"
puts "name: Test_User"
