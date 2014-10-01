class CompaniesController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => [:new, :create]

  def index
    ## FIXED
    ## FIXME_NISH We don't need to fetch the companies, as load_and_authorize_resource resouce will do it for us.
    @search = @companies.search(params[:q])
    # @companies = Company.order(:name).page(params[:page]).per(10)
    @companies = @search.result
  end

  def new
    @company = Company.new
    ## I was not able to find an alternative.
    ## FIXME_NISH Lets try if we can remove the following line.
    @company.users.build
  end

  def create
    ## FIXED
    ## FIXME_NISH Please move the params.require(:company).permit! to user_params.
    ## FIXED
    ## FIXME_NISH Please never use permit!, specify the parametes you want to allow.
    @company = Company.new(company_params)
    ## FIXED
    ## FIXME_NISH Move the following logic to models.
    ## FIXED
    ## FIXME_NISH Use responds_to
    respond_to do |format|
      if @company.save
        ## FIXED
        ## FIXME_NISH Change flash notice, add company name to it and replace was with is.
        format.html { redirect_to @company, notice: "Company #{ @company.name } is successfully created." }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def show
    ## FIXED
    ## FIXME_NISH Please don't leave extra blank lines.
  end
    ## FIXED
    ## FIXME_NISH Please remove the update method, if we don't require it.

  def toggle_enabled
    ## FIXED
    ## FIXME_NISH Use where instead of find.
    @company.toggle!(:enabled)
  end

  private
      ## FIXED
      ## FIXME_NISH why we are using this method, since we have load_and_authorize_resource.
    def company_params
      params.require(:company).permit(:name, users_attributes: [:name, :email])
    end
    ## FIXED
    ## FIXME_NISH Don't leave extra blank lines.
end
