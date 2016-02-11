class API < Grape::API
  prefix 'api'
  format :json
  formatter :json, Grape::Formatter::Jbuilder
  error_formatter :json, Formatter::Error
  mount V1::Root
end

