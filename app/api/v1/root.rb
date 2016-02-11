module V1
  module Helpers
    extend Grape::API::Helpers

    class EmitError < StandardError; end

    # 暗号化用
    SECURE = 'HOGEHOGEHOGEHOGEHOGEHOGEHOGEHOGEHOGEHOGEHOGEHOGEHOGE'
    CIPHER = 'aes-256-cbc'

    # 暗号化
    def encrypt(str)
      crypt = ActiveSupport::MessageEncryptor.new(SECURE, CIPHER)
      crypt.encrypt_and_sign(str)
    end

    # 復号化
    def decrypt(str)
      return nil if str.blank?
      crypt = ActiveSupport::MessageEncryptor.new(SECURE, CIPHER)
      crypt.decrypt_and_verify(str)
    end

    def emit_error msg, status, code
      error!({ message: msg, status: status, code: code }, status)
      # env['api.tilt.template'] = 'error'
      # env['api.tilt.locals'] = { status: status, code: code, error_msg: msg }
    end

    def emit_error! msg, status, code
      error!({ message: msg, status: status, code: code }, status)
      raise EmitError
    end

    def emit_empty
      { status: 200 }
    end


    def authenticate!
      emit_error! 'Unauthorized. Invalid or expired token.', 401, 1 unless current_user
      @current_user
    end

    def current_user
      token = ApiKey.where(access_token: params[:token]).first
      if token && !token.expired?
        @current_user = User.find(token.user_id)
      else
        false
      end
    end


		def find_user_by_id user_id
			user = User.find_by user_id: user_id
			emit_error "指定した user_id (#{user_id}) が見つかりません", 400, 1 unless user
			user
		end

    def push_notification user_id, message
      user = find_user_by_id user_id
      n = Rpush::Apns::Notification.new
      n.app = Rpush::Apns::App.find_by_name('lifenav')
      n.device_token = user.device_token
      n.alert = message
      n.save!
    end

  end

  class Root < Grape::API
    version 'v1'
    mount V1::Users
  end
end
