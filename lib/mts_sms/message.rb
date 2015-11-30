module MtsSms
  class Message
    attr_accessor :text
    attr_accessor :recipient

    def initialize text
      @text = text
    end

    def send_sms number
      @recipient = Number.new(number)
      begin
        client = Savon::Client.new(MtsSms.wsdl_api_url)
        response = client.request :send_message do
          soap.body = params
        end.to_hash
        result = { info: response, success: true }
      rescue Savon::Error => error
        result = { info: MtsSms.parse_error(self, error), success: false }
      end
      result
    end

    private

    def params
      { login: MtsSms.login,
        password: MtsSms.md5_password,
        msid: @recipient.number,
        message: @text,
        naming: MtsSms.naming }
    end
  end
end