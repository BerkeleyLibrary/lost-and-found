# frozen_string_literal: true

Rails.application.routes.draw do
  resources :posts
  root to: redirect('/auth/calnet')

  get 'home', to: 'home#index'
  get 'admin', to: 'home#admin'
  get 'health', to: 'home#health'
  get 'search_form', to: 'forms#search_form'
  post 'item_search', to:'forms#item_search'

  get '/logout', to: 'sessions#destroy', as: :logout
  get '/auth/:provider/callback', to: 'sessions#callback', as: :omniauth_callback
  get '/auth/failure', to: 'sessions#failure'

end
