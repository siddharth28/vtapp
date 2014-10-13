Rails.application.routes.draw do
  devise_for :users
  mount Ckeditor::Engine => '/ckeditor'
  devise_scope :user do
    authenticated :user do
      root 'companies#index', as: :authenticated_root

      resources :tracks do
        get :autocomplete_user_name, :on => :collection
      end

      #FIXED
      #FIXME Add routes for those actions only which are in use.
      resources :users, only: [:show, :edit]
      resources :companies, except: [:edit, :update, :destroy] do
        patch :enable, on: :member, to: :toggle_enabled
        patch :disable, on: :member, to: :toggle_enabled
      end
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
end
