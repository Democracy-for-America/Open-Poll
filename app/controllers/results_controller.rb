class ResultsController < ApplicationController
  before_action :set_poll, only: [:show]

  def show
    render(:come_back_soon) unless @poll.show_results
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll
      @poll = Poll.find_by_short_name(params[:poll])
      render(file: "#{Rails.root}/public/404", layout: false, status: '404') if @poll.nil?
    end
end