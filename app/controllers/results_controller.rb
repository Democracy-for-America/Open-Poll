class ResultsController < ApplicationController
  before_action :set_poll, only: [:show]

  def show
    render(:come_back_soon) unless @poll.show_results
    @initial_results = Rails.cache.fetch "results/initial/#{@poll.id}" do
      @poll.initial_results
    end
    @runoff_results = Rails.cache.fetch "results/runoff/#{@poll.id}" do
      @poll.runoff_results
    end

    # "Dummy" cache value.
    # When it expires, it will trigger the asynchrounous refresh of more expensive cached objects
    @timestamp = Rails.cache.fetch "foo", expires_in: 30.seconds do
      CacheRefreshJob.perform_later(@poll)
      Time.now
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll
      @poll = params[:poll] ? Poll.find_by_short_name(params[:poll]) : Domain.find_by_domain(request.host).poll rescue nil
      render(file: "#{Rails.root}/public/404", layout: false, status: '404') if @poll.nil?
    end
end