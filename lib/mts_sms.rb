require 'mts_sms/exception'
require 'mts_sms/number'
require 'mts_sms/message'
require 'savon'
require 'active_support'
require 'active_support/core_ext/object/try'

module MtsSms
  mattr_accessor :login
  mattr_accessor :md5_password
  mattr_accessor :naming
  mattr_accessor :wsdl_api_url
  mattr_accessor :logger
  @@logger = Logger.new(STDOUT)
  @@wsdl_api_url = 'http://www.mcommunicator.ru/m2m/m2m_api.asmx?WSDL'

  ERRORS_CODES = ['1', '6', '103', '506', '700', '701', '702', '703', '704', '705', '706', '707', '708', '709', '710',
                  '711', '713', '714', '715', '718']

  def self.config(attrs)
    @@login = attrs[:login]
    @@md5_password = Digest::MD5.hexdigest(attrs[:password]) if attrs[:password]
    @@naming = attrs[:naming] if attrs[:naming]
    @@wsdl_api_url = attrs[:wsdl_api_url] if attrs[:wsdl_api_url]
    @@logger = attrs[:logger] if attrs[:logger]
  end

  def self.send_sms msg, numbers
    Message.new(msg).send_sms(numbers)
  end

  def self.parse_error message, error
    error_data = error.to_hash
    code = error_data.try(:[], :fault).try(:[], :detail).try(:[], :code)
    raise MtsSms::Exception::Base.new(message, error) if code.nil? || !ERRORS_CODES.include?(code)
    error_data[:fault]
  end
end
