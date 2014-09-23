class CompaniesController < ApplicationController

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

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render action: 'show', status: :created, location: @company }
      else
        format.html { render action: 'new' }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @company = Company.find(params[:id])
  end
end
