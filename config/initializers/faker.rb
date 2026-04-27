# 本番環境以外（development または test）の時だけ実行
if Rails.env.development? || Rails.env.test?
  Faker::Config.locale = :ja
end
