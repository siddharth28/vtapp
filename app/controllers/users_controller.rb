class UsersController < ResourceController

  before_action :authenticate_user!
  before_action :remove_empty_element_multiple_select, only: [:create, :update]
  autocomplete :user, :name, full: true, extra_data: [:email], display_value: :display_details
  autocomplete :user, :department
  # rspec remaining
  skip_load_resource only: [:create]

  def index
    # FIXED
    # FIXME : sort params not correct
    ## FIXED
    ## FIXME_NISH move this logic params[:q] || { s: "name asc" } in a method.
    @search = specific_users.search(default_sort_order_if_sort_params_nil)
    @users = @search.result.includes(:roles, :company).page(params[:page])
  end

  def create
    @user = current_company.users.build(user_params)
    if @user.save
      add_or_remove_role_account_admin
      redirect_to @user, notice: "User #{ @user.name } is successfully created."
    else
      render action: :new
    end
  end

  def update
    if @user.update(update_user_params)
      add_or_remove_role_account_admin
      redirect_to @user, notice: "User #{ @user.name } is successfully updated."
    else
      render action: :edit
    end
  end


    ## FIXME_NISH this action has identical code as index, please look into it.
  private
    def user_params
      params.require(:user).permit(:name, :email, :department, :mentor_id, :enabled, tracks_with_role_runner_ids: [])
    end

    def update_user_params
      params.require(:user).permit(:name, :department, :mentor_id, :enabled, tracks_with_role_runner_ids: [])
    end

    def remove_empty_element_multiple_select
      params[:user][:tracks_with_role_runner_ids].reject!(&:blank?) if params[:user][:tracks_with_role_runner_ids]
    end

    def add_or_remove_role_account_admin
      if current_user.account_owner? && params[:account_admin?]
        @user.add_role_account_admin
      else
        @user.remove_role_account_admin
      end
    end

    def get_autocomplete_items(parameters)
      if parameters[:method] == :department
        super(parameters).with_company(current_company).group_by_department
      else
        super(parameters).with_company(current_company)
      end
    end

    def default_sort_order_if_sort_params_nil
      params[:q] || { s: "name asc" }
    end

    def specific_users
      params[:type] == 'mentees' ? current_user.mentees : current_company.users
    end

end
