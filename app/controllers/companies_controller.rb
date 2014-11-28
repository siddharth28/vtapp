class CompaniesController < ResourceController
  ## FIXME_NISH Don't add array for a single value for :only
  before_action :build_user, only: [:new]
  #rspec remaining
  ## FIXME_NISH Don't add array for a single value for :only
  skip_load_resource only: [:create]

  def index
    @search = Company.load_with_owners.search(params[:q])
    ## FIXME_NISH You don't need to explicitely specify 20, by default it will rake 25.
    @companies = @search.result.page(params[:page]).per(20)
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to @company, notice: "Company #{ @company.name } is successfully created."
    else
      render action: :new
    end
  end

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
