class CompaniesController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => [:new, :create]

  def index
    @search = @companies.search(params[:q])
    # FIXME_NISH PLEASE add pagination.
    # @companies = Company.order(:name).page(params[:page]).per(10)
    @companies = @search.result
  end

  def new
    @company = Company.new
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
      params.require(:company).permit(:name, users_attributes: [:name, :email])
    end
end
