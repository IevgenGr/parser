class SourcesController < ApplicationController
  before_action :set_source, only: %i[edit update ]

  def index
    @sources = Source.all
    @source = Source.new
  end

  def new
    @source = Source.new
  end

  def edit;  end

  def create
    @source = Source.create(source_params)
    if @source.save
      flash[:success] = 'Source added.'
      redirect_to sources_path
    else
      flash[:error] = @source.errors.full_messages
      @source.errors.full_messages
      render 'index'
    end
  end

  def update
    respond_to do |format|
      if @source.update(source_params)
        format.html { redirect_to sources_path, notice: "Source was successfully updated." }
        format.json { render :index, status: :ok, location: @source }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_source
    @source = Source.find(params[:id])
  end

  def source_params
    params.require(:source).permit(:name, :description, :country, :language)
  end
end
