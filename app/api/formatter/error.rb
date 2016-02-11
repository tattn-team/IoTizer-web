module Formatter
  module Error
    def self.call message, backtrace, options, env
      if message.is_a?(Hash)
        { :status => message[:status], :error => { :code => message[:code], :message => message[:message] } }.to_json
      else
        { error: message }.to_json
      end
    end
  end
end

