Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount_devise_token_auth_for "User", at: "auth", controllers: {
    passwords: "devise_token_auth/customized_passwords",
    registrations: "devise_token_auth/customized_registrations"
  }, defaults: { format: "json" }

  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      resources :users, only: [], param: :id do
        resource :user_setting, only: %i[show update], controller: "users/user_settings"
        resources :transactions, only: %i[index show create destroy update], controller: "users/transactions" do
          resources :positions, only: %i[update destroy], controller: "users/transactions/positions"
          collection do
            get :check_statuses
            get :summary
            get :pending
            post :mass_create
            post :create_by_hand
          end
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
