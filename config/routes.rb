Rails.application.routes.draw do
  scope path: '/territory_game' do
    root "game#index"

    resources :game, only: [:index] do
      collection do
        post :move
        post :restart
      end
    end

    get "up" => "rails/health#show", as: :rails_health_check
  end
end
