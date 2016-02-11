module V1
  class Users < Grape::API

    # このクラス内で共通化出来る処理は helper に書く
    helpers do
      include V1::Helpers    # emit_empty などを使えるようにする（必須）
		
    end

    resource :users do
      get '/' do
        "test!"
      end
    end
  end
end
