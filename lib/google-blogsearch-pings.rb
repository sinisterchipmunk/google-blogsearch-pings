require "xmlrpc/client"

module Google
  module Blogsearch
    class Ping
      attr_accessor :name, :feed_url, :site_url, :update_url, :tags
      
      def initialize(name, feed_url, options = {})
        @name, @feed_url = name, feed_url
        @site_url   = options.delete(:site)   || infer_url(feed_url)
        @update_url = options.delete(:update) || options.delete(:updated) || infer_url(feed_url)
        self.tags   = options.delete(:tags)   || []
      end
      
      def ping!
        server = XMLRPC::Client.new2("http://blogsearch.google.com/ping/RPC2")
        if tags.length == 0
          ok, param = server.call2("weblogUpdates.extendedPing", name, site_url, update_url, feed_url)
        else
          ok, param = server.call2("weblogUpdates.extendedPing", name, site_url, update_url, feed_url, tags_param)
        end
        
        if ok
          error, message = param['flerror'], param['message']
          raise message if error
          message
        else
          raise "#{param.faultString} (#{param.faultCode})"
        end
      end
      
      def tags_param
        tags.join("|")
      end

      private
      def infer_url(feed_url)
        feed_url.gsub(/^((.*?:\/\/\/?).*?(\/|$))(.*|)/, '\1')
      end
    end
  end
end
