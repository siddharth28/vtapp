class UsersController < ResourceController
  skip_load_resource only: [:index, :create]
  before_action :authenticate_user!
  before_action :remove_empty_element_multiple_select, only: [:create, :update]
  autocomplete :user, :name, full: true, extra_data: [:email], display_value: :display_user_details
  autocomplete :user, :department

  def index
    params[:q] ||= { s: "name {name:'asc'}" }
    @search = current_company.users.includes(:roles).search(params[:q])
    @users = @search.result.page(params[:page]).per(20)
  end

  def create
    @user = current_company.users.build(user_params)
    if @user.save
      redirect_to @user, notice: "User #{ @user.name } is successfully created."
    else
      render action: 'new'
    end
  end

  def update
    # FIXME : What if normal or any other user updates ?
    if @user.update(user_params)
      redirect_to @user, notice: "User #{ @user.name } is successfully updated."
    else
      render action: 'edit'
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

    def remove_empty_element_multiple_select
      params[:user][:track_ids].reject!(&:empty?)
    end

    def get_autocomplete_items(parameters)
      if parameters[:method] == :department
        super(parameters).with_company(current_company).group_by_department
      else
        # FIXME : use current_company here
        super(parameters).with_company(current_user.company)
      end
    end
end
