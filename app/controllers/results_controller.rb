class ResultsController < ApplicationController
  before_action :set_poll, only: [:show]

  def show
    render(:come_back_soon) unless @poll.show_results
    @facebook_title = @poll.results_page_og_title
    @facebook_description = @poll.results_page_og_description
    @subtitle = 'You have the power to change the results'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll
      @poll = params[:poll] ? Poll.find_by_short_name(params[:poll]) : Domain.find_by_domain(request.host).poll rescue nil
      render(file: "#{Rails.root}/public/404", layout: false, status: '404') if @poll.nil?
    end
end