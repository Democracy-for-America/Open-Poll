class VotesController < ApplicationController
  before_action :set_poll, only: [:new, :create, :show]
  skip_before_action :verify_authenticity_token

  def show
    @vote = Vote.find_by_hash params[:vote_hash]
    raise ActionController::RoutingError.new('Not Found') unless @vote
  end

  def new
    if @poll.voting_ended?
      render(:voting_has_ended)
    else
      @vote = Vote.new(poll_id: @poll.id)
      if params[:candidate_slug]
        params[:i_voted_for] = @vote.find_candidate_by_slug(params[:candidate_slug]).try(:name) or raise ActionController::RoutingError.new('Not Found')
      elsif params[:vote_hash] && @parent = Vote.find_by_hash(params[:vote_hash])
        params[:i_voted_for] = @parent.top_choice
      end
    end
  end

  def create
    @vote = Vote.new(vote_params)
    @vote.poll_id = @poll.id
    @vote.ip_address = request.remote_ip
    @vote.session_cookie = session.id
    @vote.auth_token = params[:authenticity_token]
    @vote.verified_auth_token = verified_request?
    @vote.referring_vote_id = Vote.find_by_hash(params[:vote][:referring_vote_hash]).try(:id)
    @vote.candidate_slug = params[:candidate_slug]
    respond_to do |format|
      if @vote.save(vote_params)
        VoteMailer.confirmation(@vote, @domain, params[:poll]).deliver_later
        format.html { redirect_to params[:poll] ? "/#{params[:poll]}/v/#{@vote.hash}" : "/v/#{@vote.hash}" }
      else
        format.html { render action: 'new' }
      end
    end
  end

  private
    def vote_params
      params.require(:vote).permit(:name, :zip, :email, :phone, :sms_opt_in, :first_choice, :second_choice, :third_choice, :source, :full_querystring, :referring_akid)
    end
end
