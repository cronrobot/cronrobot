Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root :to => 'home#index'

  get '/', to: 'home#index'

  namespace :dashboard do
    get '/', to: 'home#index'
    get '/schedulers', to: 'schedulers#index'
  end

  namespace :api do
    get '/test', to: 'test#index'
  end

end
