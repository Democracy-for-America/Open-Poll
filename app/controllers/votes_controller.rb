class VotesController < ApplicationController
  before_action :set_poll, only: [:new, :create, :show]

  def show
    @vote = Vote.find_by_random_hash(params[:random_hash])
  end

  def new
    if @poll.end_voting
      render(:voting_has_ended)
    else
      @vote = Vote.new(poll_id: @poll.id)
      if params['candidate_slug']
        params['i_voted_for'] = @vote.find_candidate_by_slug(params['candidate_slug']).try(:name) or raise ActionController::RoutingError.new('Not Found')
      elsif params['random_hash'] && (@parent = Vote.find_by random_hash: params['random_hash'])
        params['i_voted_for'] = @parent.top_choice
      end
    end
  end

  def create
    @vote = Vote.where(poll_id: @poll.id).find_by_email(vote_params['email'].downcase) || Vote.new(vote_params)
    @vote.poll_id = @poll.id
    @vote.ip_address = request.remote_ip
    @vote.session_cookie = session.id
    respond_to do |format|
      if @vote.update(vote_params)
        VoteMailer.confirmation(@vote, @domain, params[:poll]).deliver_later
        format.html { redirect_to params[:poll] ? "/#{params[:poll]}/v/#{@vote.random_hash}" : "/v/#{@vote.random_hash}" }
      else
        format.html { render action: 'new' }
      end
    end
  end

  private
    def vote_params
      params.require(:vote).permit(:email, :name, :zip, :first_choice, :second_choice, :third_choice, :source, :full_querystring, :referring_vote_id, :referring_akid)
    end
end
