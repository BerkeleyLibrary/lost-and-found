# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "sessions#new"

  get 'home', to: 'forms#search_form'
  get '/admin', to: 'home#admin'
  get 'health', to: 'home#health'

  resources :items
  resources :users, only: [:edit, :update, :delete, :destroy]
  resources :locations, only: [:edit, :update, :delete, :destroy]
  resources :item_types, only: [:edit, :update, :delete, :destroy]
  resources :roles, only: [:edit, :update, :delete, :destroy]

  resources :documents do
    resources :versions, only: [:destroy] do
      member do
        get :diff, to: 'versions#diff'
        patch :rollback, to: 'versions#rollback'
      end
    end
  end

  get 'search_form', to: 'forms#search_form'

get 'admin_users', to: 'home#admin_users'
get 'admin_locations', to: 'home#admin_locations'
get 'admin_item_types', to: 'home#admin_item_types'
get 'admin_items', to: 'items#admin_items'
get 'admin_roles', to: 'home#admin_roles'
get 'admin_purge', to: 'home#admin_purge'
get 'purge_items', to: 'home#admin_purge'
get 'admin_claimed', to: 'items#claimed_items'
get 'admin_migration_items', to: 'home#admin_migration_items'
get '/admin_migration_locations', to:'home#admin_migration_locations'
get '/admin_migration_item_types', to:'home#admin_migration_item_types'
get '/item_search', to: 'items#param_search'

  post '/item_search', to:'items#param_search'
  post 'item_insert', to: "items#create"
  post 'user_insert', to: "users#create"
  post 'itemType_insert', to: "item_types#create"
  post 'location_insert', to: "locations#create"
  post 'role_insert', to: "roles#create"
  post 'item_batch_insert', to: 'items#batch_upload'
  post 'location_batch_insert', to: 'locations#batch_upload'
  post 'type_batch_insert', to: 'item_types#batch_upload'
  post 'purge_items', to: 'items#purge_items'


  post 'delete_user', to: "users#destroy"
  post 'delete_item', to: "items#destroy"
  post 'location_delete', to: "locations#destroy"
  post 'itemType_delete', to: "item_types#destroy"
  post 'role_delete', to: "roles#destroy"

  post '/items/:id/items_update', to: "items#update"
  post '/users/:id/user_update', to: "users#update"
  post '/locations/:id/location_update', to: "locations#update"
  post 'item_types/:id/item_type_update', to: "item_types#update"
  post 'roles/:id/role_update', to: "roles#update"
  post 'items/:id/item_update', to: "items#update"

  get "/roles/:id/role_delete", to: "roles#destroy"
  get "/users/:id/destroy" , to: "users#destroy"
  get "/users/:id/change_status" , to: "users#change_status"
  get "/locations/:id/change_status" , to: "locations#change_status"
  get "/item_types/:id/change_status" , to: "item_types#change_status"
  get '/item_insert', to: "items#found"
  get '/found_items', to: "items#found"
  get '/logout', to: 'sessions#destroy', as: :logout
  get '/insert_form', to: 'forms#insert_form'
  get '/auth/:provider/callback', to: 'sessions#callback', as: :omniauth_callback
  get '/auth/failure', to: 'sessions#failure'
  get '*path' => redirect('/')
end
