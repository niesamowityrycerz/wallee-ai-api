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
        resource :analytics, only: [], controller: "users/analytics" do
          get :spending
          get :gross_spending
          get :spending_by_tag
          get :spending_by_category
          get :top_categories
          resources :category_pie_configs, only: %i[index create update destroy],
                    controller: "users/analytics/category_pie_configs"
        end
        resource :user_setting, only: %i[show update], controller: "users/user_settings"
        resources :tags, only: %i[index create update destroy], controller: "users/tags" do
          member do
            get :transactions
          end
        end
        resources :transactions, only: %i[index show create destroy update], controller: "users/transactions" do
          resource :tags, only: %i[create update], controller: "users/transactions/tags"
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
