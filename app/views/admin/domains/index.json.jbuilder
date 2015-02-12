json.array!(@domains) do |domain|
  json.extract! domain, :id, :domain
  json.url domain_url(domain, format: :json)
end
