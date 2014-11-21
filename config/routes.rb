Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]
  mount Ckeditor::Engine => '/ckeditor'
  devise_scope :user do
    authenticated :user do
      as :user do
        get 'users/edit' => 'devise/registrations#edit', as: :edit_user_registration
        put 'users' => 'devise/registrations#update', as: :user_registration
        get 'users/new' => 'users#new', as: :new_user
        post 'users' => 'users#create'
        get '/users/sign_out' => 'devise/sessions#destroy'
      end

      root 'roles#home_page', as: :authenticated_root

      resources :users do
        get :autocomplete_user_name, on: :collection
        get :autocomplete_user_department, on: :collection
      end

      resources :usertasks, only: [:show] do
        get :start, on: :member
        patch :submit, on: :member
      end

      namespace :tracks do
        get :search
      end

      resources :tracks do
        member do
          patch :enable, to: :toggle_enabled
          patch :disable, to: :toggle_enabled
          get :reviewers
          patch :assign_reviewer
          get :remove_reviewer
        end

        get :autocomplete_user_name, on: :collection

        resources :tasks do
          get :autocomplete_task_title, on: :collection
          get :autocomplete_user_name, on: :collection
          get :autocomplete_user_email, on: :member
          get :manage, on: :collection
          get :sample_solution, on: :member
          get :remove_sample_solution, on: :member
          # required for Sortable GUI server side actions
          post :rebuild, on: :collection
          get :reviewers, on: :member
          patch :assign_runner, on: :member
          get :remove_runner, on: :member
        end
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

    get '*unmatched_route', to: 'devise/sessions#destroy'
  end
end
