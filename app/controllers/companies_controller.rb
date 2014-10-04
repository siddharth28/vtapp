class CompaniesController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => [:create]

  def index
    @search = @companies.search(params[:q])
    # FIXME_NISH PLEASE add pagination.
    @companies = @search.result
    @companies = @companies.page(params[:page]).per(10)
  end

  def new
    @company.users.build.roles.build
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
      params.require(:company).permit(:name, users_attributes: [:name, :email, roles_attributes: [:name]])
    end
end
