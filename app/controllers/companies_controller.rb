class CompaniesController < ApplicationController

  before_action :set_company, only: [:show, :edit, :update, :destroy]

  def index
    @companies = Company.all
  end

  def new
    @company = Company.new
    @company.users.build
  end

  def create
    @company = Company.new(params.require(:company).permit!)
    @company.users.first.add_role(:account_owner)

    if @company.save
      redirect_to @company, notice: 'Company was successfully created.'
    else
      render action: 'new'
    end
  end

  def show

  end

  def update
  end

  private
    def toggle_enabled
      @company = Company.find(params[:company_id])
      @company.toggle!(:enabled)
    end

    def set_company
      @company = Company.find(params[:id])
    end

end
