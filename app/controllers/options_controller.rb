class OptionsController < ApplicationController
  before_action :set_option, only: %i[update]
  def index
    @option = Option.first
  end

  def update
    respond_to do |format|
      if @option.update(option_params)
        format.html { redirect_to options_path, notice: 'Options was successfully updated.' }
        format.json { render :index, status: :ok, location: @option }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render options_path: @option.errors, status: :unprocessable_entity }
      end
    end
  end

  def option_params
    params.require(:option).permit(:agent)
  end

  def set_option
    @option = Option.find(params[:id])
  end
end
