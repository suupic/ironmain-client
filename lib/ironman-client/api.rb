require 'net/http'
require 'rubygems'
require 'json'
require 'logger'
require 'hashie'
require 'yaml'

module Ironman
  module Client
    class API
      class << self
        def connect_to(server, port)
          @server = "http://#{server}:#{port}"
        end

	def servers_by_product_id(product_id)
	  url = "/api/v1/products/#{product_id}/servers"
	  res = get(url)
	  if res[0]['code'] == -1
	  else
            res[0]['data'].collect { |data| "#{data['server_ip_address_internal']}" if !data['server_ip_address_internal'].empty? }.compact
	  end
	end	

        private
        def get(url)
          url = "#{@server}#{url}"
          query_data(url)
        end

        def query_data(url)
          uri = URI(url)
          uri.query = URI.encode_www_form({})
	  begin
            res = Net::HTTP.get_response(uri)
            begin
              res = JSON.parse([:code => 0, :data => JSON.parse(res.body)].to_json)
	      return res
            rescue JSON::ParserError => e
	      res = JSON.parse([:code => -1, :message => "JSON::PareserError: #{res.body}"].to_json)
	      return res
            end
	  rescue Errno::ECONNREFUSED => e
            p "[ERROR] #{__FILE__}<#{__LINE__}> : #{e}"
	    exit
	  end
        end  
      end 
    end
  end
end
  

