Rails.application.routes.draw do
  devise_for :users, :skip => [:registrations]
  mount Ckeditor::Engine => '/ckeditor'
  devise_scope :user do
    authenticated :user do
      as :user do
        get 'users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
        put 'users' => 'devise/registrations#update', as: 'user_registration'
        get 'users/new' => 'users#new', as: 'new_user'
        post 'users' => 'users#create'
      end

      root 'roles#home_page', as: :authenticated_root

      resources :users
      resources :tracks do
        member do
          patch :enable, to: :toggle_enabled
          patch :disable, to: :toggle_enabled
          get :assign_track_reviewer
          get :remove_reviewer
        end
        get :autocomplete_user_name, on: :collection
      end
      resources :companies, except: [:edit, :update, :destroy] do
        member do
          patch :enable, to: :toggle_enabled
          patch :disable, to: :toggle_enabled
        end
      end
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
end
