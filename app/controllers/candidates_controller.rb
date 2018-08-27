class CandidatesController < ApplicationController
  before_action :set_poll, :set_candidate

  def show

  end

  private
    def set_candidate
      @candidate = Candidate.find params[:candidate_id]
    end
end