require 'mts_sms/exception'
require 'mts_sms/number'
require 'mts_sms/message'
require 'savon'

module MtsSms
  mattr_accessor :login
  mattr_accessor :md5_password
  mattr_accessor :naming
  mattr_accessor :wsdl_api_url
  @@wsdl_api_url = 'http://www.mcommunicator.ru/m2m/m2m_api.asmx?WSDL'

  ERRORS_CODES = ['1', '103', '506', '700', '701', '702', '703', '704', '705', '706', '707', '708', '709', '710']

  def self.config(attrs)
    @@login = attrs[:login]
    @@md5_password = Digest::MD5.hexdigest(attrs[:password])
    @@naming = attrs[:naming] if attrs[:naming]
    @@wsdl_api_url = attrs[:wsdl_api_url] if attrs[:wsdl_api_url]
  end

  def self.send_sms msg, numbers
    Message.new(msg).send_sms(numbers)
  end

  def self.parse_error message, error
    error_data = error.to_hash
    code = error_data.try(:[], :fault).try(:[], :detail).try(:[], :code)
    raise MtsSms::Exception::Base.new(message, error) if code.nil? || !ERRORS_CODES.include?(code)
    message = MtsSms::Exception::Base.generate_log_message(message, error)
    Rails.logger.debug "[MTS SMS] #{message}"
    error_data[:fault]
  end
end