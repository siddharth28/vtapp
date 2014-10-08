Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    authenticated :user do
      root 'companies#index', as: :authenticated_root
      #FIXME Add routes for those actions only which are in use.
      resources :users
      resources :companies do
        patch :enable, on: :member, to: :toggle_enabled
        patch :disable, on: :member, to: :toggle_enabled
      end
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
end
