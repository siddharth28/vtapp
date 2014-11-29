class CompaniesController < ResourceController
  ## FIXED
  ## FIXME_NISH Don't add array for a single value for :only
  before_action :build_user, only: :new
  #rspec remaining
  ## FIXED
  ## FIXME_NISH Don't add array for a single value for :only
  skip_load_resource only: :create

  def index
    ## FIXED
    ## FIXME_NISH You don't need to explicitely specify 20, by default it will rake 25.
    @search = Company.search(params[:q])
    ## FIXED
    ## FIXME_NISH Lets move includes after result.
    @companies = @search.result.includes(:owner).page(params[:page])
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
