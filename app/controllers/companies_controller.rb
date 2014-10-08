class CompaniesController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: [:index, :create]

  def index
    @companies = Company.load_with_owners
    @search = @companies.search(params[:q])
    # FIXED
    # FIXME_NISH PLEASE add pagination.
    @companies = @search.result
    @companies = @companies.page(params[:page]).per(20)
  end

  def new
    @company.users.build
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to @company, notice: "Company #{ @company.name } is successfully created."
    else
      render action: 'new'
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
