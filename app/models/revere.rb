# All Revere records are IDed with a 24-character hexidecimal string.
# For instance, DFA's main list is 5a5e354b27184079ae74ecb0.

# Usage:
# Revere.get("/list/5a5e354b27184079ae74ecb0")

require 'httparty'

class Revere
  include HTTParty

  base_uri 'https://mobile.reverehq.com/api/v1'

  headers({
    "accept" => "application/json",
    "content-type" => "application/json",
    "Authorization" => ENV['REVERE_SEND_KEY']
  })

  def self.send(**opts)
    json = {
      msisdns: [opts[:to].to_s.gsub(/\D/, '')],
      modules: [
        {
          type: "SUBSCRIPTION",
          params: {
            listId: ENV['REVERE_LIST_ID'],
            optInType: "singleOptIn",
            confirmMessage: opts[:confirm_text_message],
            # subscribedMessage: opts[:subscribed_text_message]
          }
        }
      ]
    }.to_json

    self.post("/messaging/sendContent", body: json)
  end
end
