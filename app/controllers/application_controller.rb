class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_domain

  def set_domain
    @domain = request.protocol + request.host_with_port
  end

  private
    def set_poll
      @poll = params[:poll] ? Poll.find_by_short_name(params[:poll]) : Domain.find_by_domain(request.host).poll rescue nil
      render(file: "#{Rails.root}/public/404", layout: false, status: '404') if @poll.nil?
    end
end
