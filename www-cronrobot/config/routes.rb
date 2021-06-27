Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root :to => 'home#index'

  get '/', to: 'home#index'

  get '/auth/auth0/callback' => 'auth0#callback'
  get '/auth/failure' => 'auth0#failure'
  get '/auth/logout' => 'auth0#logout'

  namespace :dashboard do
    get '/', to: 'home#index'

    get '/schedulers/', to: 'schedulers#index'
    delete '/schedulers/:id', to: 'schedulers#delete'
    get '/schedulers/new/:type', to: 'schedulers#new'

    resources :scheduler_socket_pings
  end

  

  namespace :api do
    get '/test', to: 'test#index'

    get '/resources/:id', to: 'resource#retrieve'
  end

end
