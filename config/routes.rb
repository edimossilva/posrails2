Rails.application.routes.draw do
  default_url_options :host => "localhost:3000"

  namespace :api do
    namespace :v1 do
      resources :pictures, only: %i[index create update show]
      resources :pessoas, only: %i[index create update show destroy]
    end
  end
end
