class VotesController < ApplicationController
  before_action :set_poll, only: [:new, :create, :show]

  def show
    @vote = Vote.find_by_random_hash(params[:random_hash])
  end

  def new
    @vote = Vote.new({poll_id: @poll.id})
  end

  def create
    @vote = Vote.where(poll_id: @poll.id).find_by_email(vote_params['email']) || Vote.new(vote_params)
    @vote.poll_id = @poll.id
    @vote.ip_address = request.remote_ip
    @vote.session_cookie = session.id
    # drag = params[:drag]
    respond_to do |format|
      if @vote.update(vote_params)
        VoteMailer.confirmation(@vote, @domain).deliver_later
        format.html { redirect_to "/polls/#{params[:poll]}/votes/#{@vote.random_hash}" }
      else
        format.html { render action: 'new' }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll
      @poll = Poll.find_by_short_name(params[:poll])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vote_params
      params.require(:vote).permit(:email, :name, :zip, :first_choice, :second_choice, :third_choice, :source, :full_querystring, :referring_vote_id, :referring_akid)
    end
end
