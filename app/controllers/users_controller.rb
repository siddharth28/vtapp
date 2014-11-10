class UsersController < ResourceController

  before_action :authenticate_user!
  before_action :remove_empty_element_multiple_select, only: [:create, :update]
  autocomplete :user, :name, full: true, extra_data: [:email], display_value: :display_user_details
  autocomplete :user, :department
  # rspec remaining
  skip_load_resource only: [:create]

  def index
    @search = current_company.users.includes(:roles).search(params[:q] || { s: "name {name:'asc'}" })
    @users = @search.result.page(params[:page]).per(20)
  end

  def create
    @user = current_company.users.build(user_params)
    if @user.save
      redirect_to @user, notice: "User #{ @user.name } is successfully created."
    else
      render action: :new
    end
  end

  def update
    if @user.update(update_user_params)
      redirect_to @user, notice: "User #{ @user.name } is successfully updated."
    else
      render action: :edit
    end
  end

  private
    def user_params
      if current_user.account_owner?
        params.require(:user).permit(:name, :email, :department, :mentor_id, :is_admin, :enabled, track_ids: [])
      elsif current_user.account_admin?
        params.require(:user).permit(:name, :email, :department, :mentor_id, :enabled, track_ids: [])
      end
    end

    def update_user_params
      if current_user.account_owner?
        params.require(:user).permit(:name, :department, :mentor_id, :is_admin, :enabled, track_ids: [])
      elsif current_user.account_admin?
        params.require(:user).permit(:name, :department, :mentor_id, :enabled, track_ids: [])
      end
    end

    def remove_empty_element_multiple_select
      params[:user][:track_ids].reject!(&:blank?)
    end

    def get_autocomplete_items(parameters)
      if parameters[:method] == :department
        super(parameters).with_company(current_company).group_by_department
      else
        super(parameters).with_company(current_company)
      end
    end
end
