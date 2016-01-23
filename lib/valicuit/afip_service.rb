require 'net/http'
require 'openssl'
require 'json'

module Valicuit
  class AfipServiceDownException < Net::ReadTimeout; end

  class AfipService
    DEFAULT_ENDPOINT = 'https://soa.afip.gob.ar/sr-padron/v2/persona/:cuit'.freeze
    DEFAULT_TIMEOUT  = 3

    attr_accessor :endpoint, :timeout

    def initialize(endpoint: DEFAULT_ENDPOINT, timeout: DEFAULT_TIMEOUT)
      self.endpoint = endpoint
      self.timeout  = timeout
    end

    def cuit_exists?(cuit)
      person_from(cuit)['success']
    end

    protected

    # Get the AFIP person data as a hash
    def person_from(cuit)
      JSON.parse http_person_from(cuit).body
    end

    # Get the AFIP person data as a raw http response
    def http_person_from(cuit)
      cuit = sanitize_cuit cuit
      complete_endpoint = endpoint.gsub(':cuit', cuit)
      uri = URI.parse complete_endpoint
      begin
        do_http_get_to_afip uri
      rescue Net::ReadTimeout
        raise AfipServiceDownException
      end
    end

    # Just in case... only numbers will be sent
    def sanitize_cuit(cuit)
      cuit.to_s.gsub /[^\d]/, ''
    end

    def do_http_get_to_afip(uri)
      http = Net::HTTP.new(uri.host, uri.port).tap do |http|
        http.read_timeout = timeout
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Get.new uri.request_uri
      http.request request
    end
  end
end
