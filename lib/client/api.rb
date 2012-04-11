require 'net/http'
require 'rubygems'
require 'json'
require 'logger'
require 'hashie'

module Ironman
  module Client
    class API
      def connect_to(server, port)
	@server = "http://#{server}:#{port}"
      end

      def get(resource)
        url = "http://#{@server}#{page}"
	query_data(url)
      end

      private
      def query_data(url)
	uri = URI(url)
        uri.query = URI.encode_www_form({})
        res = Net::HTTP.get_response(uri)
        begin
          message_j = JSON.parse(res.body)
        rescue JSON::ParserError => e
          "JSON::PareserError".to_json
        end
      end   
    end
  end
end
  

