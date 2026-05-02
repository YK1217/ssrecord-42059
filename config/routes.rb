Rails.application.routes.draw do
  devise_for :users

  root "daily_records#index"

  resource :user, only: [:show]
  resources :study_records, only: [:new, :create,:destroy, :edit, :update]
  resources :sleep_records, only: [:new, :create,:destroy, :edit, :update]
end
