Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    authenticated :user do
      root 'companies#index', as: :authenticated_root
      resources :users
      resources :companies do
        patch :toggle_enabled, on: :member
      end
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
end
