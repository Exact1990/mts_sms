module MtsSms
  module Exception
    class Base < ::Exception
      def initialize message, error
        msg = Base.generate_log_message(message, error)
        super(msg)
      end

      def self.generate_log_message(message, error)
        "INFO: [number=#{message.recipient.number}], [message=#{message.text}]\n" \
        "TITLE: #{error.message}\n" \
        "BACKTRACE: #{error.backtrace}"
      end
    end
  end
end

