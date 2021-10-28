# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'sessions#new', as: :login

  get '/home', to: 'forms#search_form'
  get '/admin', to: 'home#admin'
  get '/health', to: 'home#health'

  # TODO: clean these up
  resources :items
  resources :users, only: %i[edit update delete destroy]
  resources :locations, only: %i[edit update delete destroy]
  resources :item_types, only: %i[edit update delete destroy]
  resources :roles, only: %i[edit update delete destroy]

  get '/insert_form', to: 'forms#insert_form'
  get '/search_form', to: 'forms#search_form'

  get '/admin_item_types', to: 'home#admin_item_types'
  get '/admin_locations', to: 'home#admin_locations'
  get '/admin_purge', to: 'home#admin_purge'
  get '/admin_users', to: 'home#admin_users'

  get '/item_types/:id/change_status', to: 'item_types#change_status', as: :toggle_item_type_status
  post '/itemType_insert', to: 'item_types#create'
  post '/itemType_delete', to: 'item_types#destroy'
  post '/item_types/:id/item_type_update', to: 'item_types#update'

  get '/items', to: 'items#index'

  get '/admin_items', to: 'items#admin_items'
  get '/admin_claimed', to: 'items#claimed_items'
  post '/item_insert', to: 'items#create'
  post '/delete_item', to: 'items#destroy'
  post '/purge_items', to: 'items#purge_items'
  post '/items/:id/item_update', to: 'items#update', as: :item_update

  get '/locations/:id/change_status', to: 'locations#change_status', as: :toggle_location_status
  post '/location_insert', to: 'locations#create'
  post '/location_delete', to: 'locations#destroy'
  post '/locations/:id/location_update', to: 'locations#update'

  get '/auth/:provider/callback', to: 'sessions#callback', as: :omniauth_callback

  get '/logout', to: 'sessions#destroy', as: :logout
  get '/auth/failure', to: 'sessions#failure'

  get '/users/:id/change_status', to: 'users#change_status', as: :toggle_user_status
  post '/user_insert', to: 'users#create'
  get '/users/:id/destroy', to: 'users#destroy'
  post '/delete_user', to: 'users#destroy'
  post '/users/:id/user_update', to: 'users#update'

  get '*all', to: redirect { |_, req| "/?404=#{req.path}" }, constraints: ->(req) do
    req.path.exclude? 'rails/active_storage'
  end
end
