class CompaniesController < ResourceController
  before_action :build_user, only: :new
  #rspec remaining
  skip_load_resource only: :create

  def index
    @search = Company.search(params[:q])
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
