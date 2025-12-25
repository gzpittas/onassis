Rails.application.routes.draw do
  root "timeline#index"

  resources :entries
  resources :characters do
    resources :casting_candidates, except: [:index]
  end
  resources :sources
  resources :articles
  resources :images
  resources :assets, path: "production_assets"
  resources :locations
  resources :musics, path: "music"
  resources :videos
  resources :credits do
    resources :credit_candidates, except: [:index]
  end

  get "timeline", to: "timeline#index"
  get "search", to: "search#index"
  get "help", to: "help#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
