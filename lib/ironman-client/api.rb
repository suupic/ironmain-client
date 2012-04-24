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
	  @logger = Logger.new("/var/log/ironman-client.log", 10, 30*1024*1024)
        end

	def servers_list_for(product_name)
	  url = "/api/v1/products/#{product_name}"
	  m = get(url)
	  m.server_ip_list
	end	

	def products_list
	  url = "/api/v1/products"

	  m = get(url)
	  m.products_list
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
	  rescue Net::HTTPNotFound
            @logger.debug "404 not found when Query: #{url}"
	    exit 1
          rescue e
            @logger.error "#{e}"
	  end

	  begin
            res = JSON.parse(res.body)
	  rescue
            @logger.error "Parse Error when load data from #{url}"
            @logger.error "data: #{res.body}"
            exit 1
          end

          m = Hashie::Mash.new(res)
	  if m.run_status == 0 
	    return m
	  else
            @logger.error "Server returns FAILED when query #{url}, check url's parameters or server's log"
            exit 1
	  end
        end  
      end 
    end
  end
end
  

