class CompaniesController < ResourceController
  #FIXME Rspecs of this line.
  skip_load_resource only: [:index, :create]

  def index
    @search = Company.load_with_owners.search(params[:q])
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

end
