class AzuriteClient

  def initialize
    #TODO init managers here, pass self in
    @token   = nil #TODO token received from api after login
  end

  def login(&block)
    #TODO Should call api to login with trainer DTO, should respond with token
    #body = {"player_data" => Package.seal(@player_data)}
    #response = request(:post, "/login", false, body, &block)
    #return :error unless response
    #case response[:status]
    #when 200
    #  body = response[:body]
    #  @access_token = body['token']
    #  @verified     = body['verified']
    #  echoln(@access_token)
    #  return :login
    #when 201
    #  body = response[:body]
    #  @access_token         = body['token']
    #  @verified             = body['verified']
    #  $player.online_id     = body['online_id']
    #  $player.online_secret = body['online_secret']
    # refresh_player_data
    # return :registered
    #when 401
    #  return :unauthorized
    #when 403
    #  return :banned
    #when 426
    #  return :need_update
    #end
  end

  def request(method, route, authorization = nil, body = nil, retries = 3, &block)
    body = body ? HTTPLite::JSON.stringify(body) : HTTPLite::JSON.stringify({})
    headers = {}
    #headers['Authorization'] = "Bearer #{@access_token}" if authorization && @access_token
    response = nil
    attempt = 0
    begin
      if block_given?
        thr = Thread.new {
          case method
          when :get
            thr[:response] = HTTPLite.get(OnlineResources::URL + route, headers)
          when :post
            thr[:response] = HTTPLite.post_body(OnlineResources::URL + route, body, "application/json", headers)
          end
        }
        loop do
          Graphics.update
          Input.update
          yield
          break unless thr.alive?
        end
        response = thr[:response]
      else
        case method
        when :get
          response = HTTPLite.get(OnlineResources::URL + route, headers)
        when :post
          response = HTTPLite.post_body(OnlineResources::URL + route, body, "application/json", headers)
        end
      end
      raise if response[:status] >= 500
      response[:body] = HTTPLite::JSON.parse(response[:body]) unless response[:body].empty?
      return response
    rescue StandardError, MKXPError
      attempt += 1
      retry if  attempt < retries
      return false
    rescue Exception
    end
  end

  def async_request(method, route, authorization = nil, body = nil, retries = 3, &block)
    body = body ? HTTPLite::JSON.stringify(body) : HTTPLite::JSON.stringify({})
    headers = {}
    #headers['Authorization'] = "Bearer #{@access_token}" if authorization && @access_token
    thr = Thread.new {
      attempt = 0
      begin
        case method
        when :get
          thr[:response] = HTTPLite.get(OnlineResources::URL + route, headers)
        when :post
          thr[:response] = HTTPLite.post_body(OnlineResources::URL + route, body, "application/json", headers)
        end
        thr[:response][:body] = HTTPLite::JSON.parse(thr[:response][:body]) unless thr[:response][:body].empty?
        yield thr[:response]
      rescue StandardError, MKXPError
        attempt += 1
        retry if attempt < retries
        yield nil
      rescue Exception
        yield nil
      end
    }
  end

  def ping_server
    response = request(:get, OnlineResources::Info::PING)
    return true if response&[:status] == 200
    return false
  end
end

AzuriteClient.new.ping_server