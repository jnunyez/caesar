require 'uri'

module Reducers
  class ExternalReducer < Reducer
    class ExternalReducerFailed < StandardError; end

    config_field :url, default: nil

    validate do
      if url.present?
        schemes = ['https']

        begin
          uri = URI.parse(url)
          unless uri && uri.host && schemes.include?(uri.scheme)
            errors.add(:url, "URL must be one of: #{schemes.join(",")}")
          end
        rescue URI::InvalidURIError
          errors.add(:url, "URL could not be parsed")
        end
      end
    end

    def reduction_data_for(extractions)
      if url
        response = RestClient.post(url, extractions.to_json, {content_type: :json, accept: :json})

        if response.code == 204
          NoData
        elsif ([200, 201, 202].include? response.code) and response.body.present?
          JSON.parse(response.body)
        else
          raise StandardError.new 'Remote reducer failed'
        end
      else
        raise StandardError.new "External extractor improperly configured: no URL"
      end
    rescue RestClient::InternalServerError
      raise ExternalReducerFailed
    end
  end
end
