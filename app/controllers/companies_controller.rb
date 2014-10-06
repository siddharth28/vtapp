class CompaniesController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: [:index, :create]

  def index
    @companies = Company.owner
    @search = @companies.search(params[:q])
    # FIXME_NISH PLEASE add pagination.
    @companies = @search.result
    @companies = @companies.page(params[:page]).per(2)
  end

  def new
    @company.users.build
  end

  def create
    @company = Company.new(company_params)
    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: "Company #{ @company.name } is successfully created." }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def show
  end

  def toggle_enabled
    @company.toggle!(:enabled)
  end

  private
    def company_params
      params.require(:company).permit(:name, :owner_name, :owner_email)
    end

end
