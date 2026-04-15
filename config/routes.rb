Rails.application.routes.draw do
  get 'users/show'
  get 'homes/top'
  devise_for :users

  root "homes#top"
  resource :user, only: [:show]
end
