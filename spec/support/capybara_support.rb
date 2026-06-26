require 'selenium/webdriver'

Capybara.register_driver :ssrecord_selenium_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  # シークレットウィンドウで起動
  options.add_argument('--incognito')

  # Chromeのパスワード保存・警告系の表示を抑制
  options.add_argument('--disable-save-password-bubble')
  options.add_argument('--disable-password-manager-reauthentication')
  options.add_argument('--disable-features=PasswordLeakDetection,PasswordManagerOnboarding')

  options.add_preference('credentials_enable_service', false)
  options.add_preference('profile.password_manager_enabled', false)
  options.add_preference('profile.password_manager_leak_detection', false)

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.default_driver = :ssrecord_selenium_chrome
Capybara.javascript_driver = :ssrecord_selenium_chrome

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :ssrecord_selenium_chrome
  end
end
