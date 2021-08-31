Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root :to => 'home#index'

  get '/', to: 'home#index'
  get '/privacy-policy', to: 'home#privacy_policy'
  get '/terms', to: 'home#terms'

  get '/auth/auth0/callback' => 'auth0#callback'
  get '/auth/failure' => 'auth0#failure'
  get '/auth/logout' => 'auth0#logout'

  namespace :dashboard do
    get '/', to: 'home#index'

    get '/schedulers/', to: 'schedulers#index'
    get '/schedulers/new/:type', to: 'schedulers#new'
    post '/schedulers/:id/pause', to: 'schedulers#pause'
    post '/schedulers/:id/unpause', to: 'schedulers#unpause'
    delete '/schedulers/:id', to: 'schedulers#delete'

    resources :scheduler_socket_pings
    resources :scheduler_https
    resources :scheduler_sshes

    resources :notification_channels
    resources :resources

    get '/support', to: 'support#index'
    post '/support', to: 'support#contact'
  end

  namespace :api do
    get '/test', to: 'test#index'

    get '/resources/:id', to: 'resource#retrieve'
    get '/projects/:project_id/resources/:type', to: 'resource#retrieve_project_resources'
  end

end
