class UsersController < ResourceController
  skip_load_resource only: [:index, :create]
  before_action :authenticate_user!
  before_action :remove_empty_element_multiple_select, only: [:create, :update]
  autocomplete :user, :name, full: true
  autocomplete :user, :department

  def index
    #FIXED
    #FIXME : memoize current_user.company to current_company
    @search = current_company.users.eager_load(:roles).search(params[:q])
    @users = @search.result.page(params[:page]).per(20)
  end

  def create
    #FIXED
    #FIXME : memoize current_user.company to current_company
    @user = current_company.users.build(user_params)
    if @user.save
      #FIXME : Typo, 'user' should be with capital 'u'
      redirect_to @user, notice: "User #{ @user.name } is successfully created."
    else
      render action: 'new'
    end
  end

  def update
    if @user.update(user_params)
      #FIXME : Typo, 'user' should be with capital 'u'
      redirect_to @user, notice: "User #{ @user.name } is successfully updated."
    else
      render action: 'edit'
    end
  end

  private
    def user_params
      #FIXME : create dynamic method for account_owner?
      if current_user.account_owner?
        params.require(:user).permit(:name, :email, :department, :mentor_id, :admin, :enabled, track_ids: [])
      elsif current_user.account_admin?
        #FIXME : create dynamic method for admin?
        params.require(:user).permit(:name, :email, :department, :mentor_id, :enabled, track_ids: [])
      end
    end

    def remove_empty_element_multiple_select
      params[:user][:track_ids].reject!(&:empty?)
    end
    def get_autocomplete_items(parameters)
      #FIXME : create scope for company
      super(parameters).where(company_id: current_user.company_id).group(:department)
    end
end
