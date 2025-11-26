# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'sessions#new', as: :login

  get '/home', to: 'forms#search_form'
  get '/admin', to: 'home#admin'
  get '/health', to: 'ok_computer/ok_computer#index', defaults: { format: :json }

  # TODO: clean these all up

  resources :items, only: %i[index create show edit update destroy]
  get '/insert_form', to: 'forms#insert_form', as: :new_item
  post '/items/:id/item_update', to: 'items#update', as: :item_update
  get '/search_form', to: 'forms#search_form'

  get '/admin_items', to: 'items#admin_items' # TODO: is this used?
  get '/admin_claimed', to: 'items#claimed_items'
  get '/admin_purge', to: 'home#admin_purge'
  post '/purge_items', to: 'items#purge_items'

  resources :users, only: %i[edit update destroy]
  get '/admin_users', to: 'home#admin_users'
  get '/users/:id/change_status', to: 'users#change_status', as: :toggle_user_status
  get '/users/:id/destroy', to: 'users#destroy'
  post '/delete_user', to: 'users#destroy'
  post '/user_insert', to: 'users#create'
  post '/users/:id/user_update', to: 'users#update'

  resources :locations, only: %i[edit update destroy]
  get '/admin_locations', to: 'home#admin_locations'
  get '/locations/:id/change_status', to: 'locations#change_status', as: :toggle_location_status
  post '/location_insert', to: 'locations#create'
  post '/location_delete', to: 'locations#destroy'
  post '/locations/:id/location_update', to: 'locations#update'

  resources :item_types, only: %i[edit update destroy]
  get '/admin_item_types', to: 'home#admin_item_types'
  get '/item_types/:id/change_status', to: 'item_types#change_status', as: :toggle_item_type_status
  post '/item_type_insert', to: 'item_types#create'
  post '/item_type_delete', to: 'item_types#destroy'
  post '/item_types/:id/item_type_update', to: 'item_types#update'

  get '/logout', to: 'sessions#destroy', as: :logout
  get '/auth/failure', to: 'sessions#failure'
  get '/auth/:provider/callback', to: 'sessions#callback', as: :omniauth_callback

  get '*all', to: redirect { |_, req| "/?404=#{req.path}" }, constraints: ->(req) do
    req.path.exclude? 'rails/active_storage'
  end
end
