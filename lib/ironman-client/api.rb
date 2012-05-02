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

	#根据产品名称获取部署服务器列表
	def servers_list_for(product_name)
	  url = "/api/v1/products/#{product_name}"
	  m = get(url)
	  m.server_ip_list
	end	

	#根据产品名称获得产品部署路径
	def deploy_path_for(product_name)
	  url = "/api/v1/products/#{product_name}"
	  m = get(url)
	  m.deploy_path
	end	

	#所有产品列表
	def products_list
	  url = "/api/v1/products"
	  m = get(url)
	  m.products_list
	end	

	#根据ip获得服务器ssh端口
	def ssh_port_for(server_ip)
	  url = "/api/v1/server/ip"
	  m = get(url,:ip => server_ip)
	  m.ssh_port
	end	

        private
        def get(url, params={})
          url = "#{@server}#{url}"
          query_data(url, params)
        end

        def query_data(url,params)
          uri = URI(url)
          uri.query = URI.encode_www_form(params)

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
	    @logger.error m
            exit 1
	  end
        end  
      end 
    end
  end
end
  

