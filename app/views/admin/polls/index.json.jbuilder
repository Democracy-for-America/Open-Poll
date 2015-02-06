json.array!(@polls) do |poll|
  json.extract! poll, :id, :title, :subtitle, :short_name, :end_voting, :show_results
  json.url poll_url(poll, format: :json)
end
