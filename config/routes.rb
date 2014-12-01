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
      get '/:type', to: 'users#index', constraints: { type: :mentees }
      resources :users do
        collection do
          get :autocomplete_user_name
          get :autocomplete_user_department
        end
      end

      resources :usertasks, only: [:show] do
        member do
          get :start
          get :restart
          post :submit_comment
          post :submit_url
          get :submit_task
          post :resubmit
          put :assign_to_me
          get :review
          patch :review_exercise
          get :search
        end
      end

      resources :tracks do
        member do
          patch :enable, to: :toggle_enabled
          patch :disable, to: :toggle_enabled
          get :reviewers
          patch :assign_reviewer
          get :remove_reviewer
          get :runners
          get :status
        end

        get :autocomplete_user_name, on: :collection

        resources :tasks do
          collection do
            get :autocomplete_task_title
            get :autocomplete_user_name
            # required for Sortable GUI server side actions
            post :rebuild
            get :manage
            get :to_review
            get :assigned_to_others_for_review
            get :list
          end
          member do
            get :download_sample_solution
            get :remove_sample_solution
            get :autocomplete_user_email
            get :reviewers
            patch :assign_runner
            get :remove_runner
          end
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

    ## FIXME_NISH why we have written the following line?
    get '*unmatched_route', to: 'devise/sessions#destroy'
  end
end
