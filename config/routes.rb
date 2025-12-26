Rails.application.routes.draw do
  root "timeline#index"

  resources :entries
  resources :characters do
    resources :casting_candidates, except: [:index]
  end
  resources :sources
  resources :articles
  resources :images

  # Smart AI-powered import
  get "smart_import", to: "smart_imports#new", as: :smart_import
  post "smart_import/fetch_images", to: "smart_imports#fetch_images", as: :smart_import_fetch_images
  post "smart_import/analyze", to: "smart_imports#analyze", as: :smart_import_analyze
  post "smart_import", to: "smart_imports#create", as: :create_smart_import
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
