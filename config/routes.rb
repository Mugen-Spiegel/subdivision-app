Rails.application.routes.draw do


  
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations', path_names: { :sign_in => "login", :sign_out => "logout", :sign_upppp => "register" },
    passwords: 'users/passwords'
  }

  
   mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  resources :residence do
    collection do
      get "residence_list"
    end 
  end
  

  resources :subdivision
  resources :water_billing_transaction
  resources :water_billing do
    member do
      post "upload_image"
    end
  end
  # Defines the root path route ("/")
  root "subdivision#index"
end
