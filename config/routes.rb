# frozen_string_literal: true

Rails.application.routes.draw do

  resources :posts
  root to: redirect('/auth/calnet')

  get 'home', to: 'home#index'
  get '/admin', to: 'home#admin'
  get 'health', to: 'home#health'

  resources :items do
    member do
      get :delete
    end
  end

  get 'search_form', to: 'forms#search_form'
  post '/item_search', to:'items#param_search'
  post 'item_insert', to: "items#create"
  post 'user_insert', to: "users#create"
  post 'itemType_insert', to: "item_types#create"
  post 'location_insert', to: "locations#create"
  post 'role_insert', to: "roles#create"

  post 'delete_user', to: "users#destroy"
  post 'delete_item', to: "items#destroy"
  post 'location_delete', to: "locations#destroy"
  post 'itemType_delete', to: "item_types#destroy"
  post 'role_delete', to: "roles#destroy"
  get '/item_all', to: "items#all"

  get '/logout', to: 'sessions#destroy', as: :logout
  get '/insert_form', to: 'forms#insert_form'
  get '/auth/:provider/callback', to: 'sessions#callback', as: :omniauth_callback
  get '/auth/failure', to: 'sessions#failure'
end
