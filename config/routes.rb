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

      namespace :usertasks do
        get :start_task
        get :task_description
        patch :submit_task
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
          get :manage, on: :collection
          get :sample_solution, on: :member
          # required for Sortable GUI server side actions
          post :rebuild, on: :collection
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
  end
end
