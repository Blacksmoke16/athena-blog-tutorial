@[ADI::Register("@user_storage", tags: ["athena.event_dispatcher.listener"])]
struct Blog::Listeners::SecurityListener
  include AED::EventListenerInterface
  include ADI::Service

  def self.subscribed_events : AED::SubscribedEvents
    AED::SubscribedEvents{
      ART::Events::Request => 10,
    }
  end

  def initialize(@user_storage : UserStorage); end

  def call(event : ART::Events::Request, _dispatcher : AED::EventDispatcherInterface) : Nil
    # Allow POST user and POST login through since they are public
    # In the future Athena will most likely have a more structured way to handle auth
    if event.request.method == "POST" && {"/user", "/login"}.includes? event.request.path
      return
    end

    # Return a 401 error if the token is missing or malformed
    raise ART::Exceptions::Unauthorized.new "Bearer realm=\"My Blog\"", "Missing bearer token" unless (auth_header = event.request.headers.get?("Authorization").try &.first) && auth_header.starts_with? "Bearer "

    # Get the JWT token from the Bearer header
    token = auth_header.lchop "Bearer "

    begin
      # Validate the token
      body = JWT.decode token, ENV["SECRET"], :hs512
    rescue decode_error : JWT::DecodeError
      # Throw a 401 error if the JWT token is invalid
      raise ART::Exceptions::Unauthorized.new "Bearer realm=\"My Blog\"", "Invalid token"
    end

    # Set the user in user storage
    @user_storage.user = Blog::Models::User.find! body[0]["user_id"]
  end
end
