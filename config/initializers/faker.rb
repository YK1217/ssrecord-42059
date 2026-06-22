# 本番環境以外（development または test）の時だけ実行
Faker::Config.locale = :ja if Rails.env.local?
