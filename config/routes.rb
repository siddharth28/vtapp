Rails.application.routes.draw do
  devise_for :users, :skip => [:registrations]
  mount Ckeditor::Engine => '/ckeditor'
  devise_scope :user do
    authenticated :user do
      as :user do
        get 'users/edit' => 'devise/registrations#edit', as: :edit_user_registration
        put 'users' => 'devise/registrations#update', as: :user_registration
        get 'users/new' => 'users#new', as: :new_user
        post 'users' => 'users#create'
      end
      root 'roles#home_page', as: :authenticated_root
      resources :users do
        get :autocomplete_user_name, on: :collection
        get :autocomplete_user_department, on: :collection
      end

      resources :tracks do
        get :autocomplete_user_name, on: :collection
      end
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
