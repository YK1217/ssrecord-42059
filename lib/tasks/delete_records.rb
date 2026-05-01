unless Rails.env.development?
  puts "development環境以外では実行できません"
  exit
end

email = "test@example.ne.jp"

user = User.find_by(email: email)

if user.nil?
  puts "ユーザーが見つかりません"
  exit
end

deleted_count = user.study_records.delete_all

puts "#{deleted_count}件のstudy_recordsを削除しました"

deleted_count = user.sleep_records.delete_all

puts "#{deleted_count}件のsleep_recordsを削除しました"
