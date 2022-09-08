Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  resources :tasks
  resources :users
  resources :categories, only: %i(index create destroy edit update)
  resources :admin, only: %i(index show update)
  resources :account_activations, only: :edit

  root 'sessions#new'

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  delete '/admin',   to: 'users#destroy'
end
