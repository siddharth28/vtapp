class CompaniesController < ResourceController

  before_action :build_user, only: [:new]

  def index
    #FIXED
    #FIXME -> We are using @search varible. Please include it again.
    #No we do not need this variable it's just to increase the readability
    #FIXME_AB: Do we need this instance variable @search, do we need this in views
    @search = Company.load_with_owners.search(params[:q])
    @companies = @search.result.page(params[:page]).per(20)
  end

    #FIXED
    #FIXME : I think this is not the part of new action, we can move this to before_action

  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to @company, notice: "Company #{ @company.name } is successfully created."
    else
      render action: :new
    end
  end
  # Sir why do we need seperate actions for this when we will be doing the same thing in both the actions.
  #FIXME_AB: You should have two actions for this one enable, other disable
  def toggle_enabled
    @company.toggle!(:enabled)
  end

  private
    def company_params
      params.require(:company).permit(:name, :owner_name, :owner_email)
    end

    def build_user
      @company.users.build
    end

end
