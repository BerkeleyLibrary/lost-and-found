# frozen_string_literal: true

Rails.application.routes.draw do
  resources :posts
  get 'admin', to: 'home#admin'
  get 'health', to: 'home#health'
  get 'home', to: 'home#index'

  get '/login', to: 'sessions#new', as: :login
  get '/logout', to: 'sessions#destroy', as: :logout
  get '/auth/:provider/callback', to: 'sessions#callback', as: :omniauth_callback
  get '/auth/failure', to: 'sessions#failure'

end
