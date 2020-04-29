# frozen_string_literal: true

Rails.application.routes.draw do
  resources :posts
  get '/', to: 'home#index'
  get 'admin', to: 'home#admin'
  get 'health', to: 'home#health'
  get 'home', to: 'home#index'
  get 'search_form', to: 'forms#search_form'

  post 'item_search', to:'forms#item_search'
  get '/login', to: 'sessions#new', as: :login
  get '/logout', to: 'sessions#destroy', as: :logout
  post '/auth/:provider/callback', to: 'sessions#callback', as: :omniauth_callback
  get '/auth/failure', to: 'sessions#failure'

end
