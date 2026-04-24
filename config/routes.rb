Rails.application.routes.draw do
  devise_for :users

  root "homes#top"
  resource :user, only: [:show]
  resources :study_records, only: [:new, :create]
end
