json.array!(@candidates) do |candidate|
  json.extract! candidate, :id, :name, :office, :show_on_ballot, :show_in_results
  json.url candidate_url(candidate, format: :json)
end
