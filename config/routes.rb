Rails.application.routes.draw do
  default_url_options :host => "localhost:3000"

  namespace :api do
    namespace :v1 do
      resources :people, only: %i[index create update show destroy]
    end
  end
end
