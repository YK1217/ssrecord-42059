module SignInSupport
  def sign_in(user)
    visit root_path

    expect(page).to have_current_path(new_user_session_path)

    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: user.password
    click_button 'ログイン'

    expect(page).to have_current_path(root_path)
  end
end
