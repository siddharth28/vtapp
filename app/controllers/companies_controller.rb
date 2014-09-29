class CompaniesController < ApplicationController
  load_and_authorize_resource

  before_action :set_company, only: [:show, :edit, :update, :destroy]

  def index
    ## FIXME_NISH We don't need to fetch the companies, as load_and_authorize_resource resouce will do it for us.
    @companies = Company.all
  end

  def new
    @company = Company.new
    ## FIXME_NISH Lets try if we can remove the following line.
    @company.users.build
  end

  def create
    ## FIXME_NISH Please move the params.require(:company).permit! to user_params.
    ## FIXME_NISH Please never use permit!, specify the parametes you want to allow.
    @company = Company.new(params.require(:company).permit!)

    ## FIXME_NISH Move the following logic to models.
    @company.users.first.add_role(:account_owner)

    ## FIXME_NISH Use responds_to

    if @company.save
      ## FIXME_NISH Change flash notice, add company name to it and replace was with is.
      redirect_to @company, notice: 'Company was successfully created.'
    else
      render action: 'new'
    end
  end

  def show
    ## FIXME_NISH Please don't leave extra blank lines.

  end

  def update
    ## FIXME_NISH Please remove the update method, if we don't require it.
  end

  def toggle_enabled
    ## FIXME_NISH Use where instead of find.
    @company = Company.find(params[:company_id])
    @company.toggle!(:enabled)
  end

  private
    def set_company
      ## FIXME_NISH why we are using this method, since we have load_and_authorize_resource.
      @company = Company.find(params[:id])
    end
     ## FIXME_NISH Don't leave extra blank lines.
end
