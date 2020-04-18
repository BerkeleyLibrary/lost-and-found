# frozen_string_literal: true

Rails.application.routes.draw do
  get '/', to: 'home#index'
  get 'admin', to: 'home#admin'
  get 'health', to: 'home#health'
  get 'home', to: 'home#index'
  get 'search_form', to: 'forms#search_form'
  

  resources :items do
    member do
      get :delete
    end
  end

  post '/item_search', to:'items#param_search'
  post 'item_insert', to: "items#create"
  get '/item_all', to: "items#all"

<<<<<<< HEAD
  resources :items do
    member do
      get :delete
    end
  end

  post '/item_search', to:'items#param_search'
  post 'item_insert', to: "items#create"
  get '/item_all', to: "items#all"

=======
>>>>>>> Adding basic CRUD features to insert and search on keywords
  get '/login', to: 'sessions#new', as: :login
  get '/logout', to: 'sessions#destroy', as: :logout
  get '/insert_form', to: 'forms#insert_form'
  post '/auth/:provider/callback', to: 'sessions#callback', as: :omniauth_callback
  get '/auth/failure', to: 'sessions#failure'

end
