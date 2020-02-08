@[ADI::Register("@user_storage", tags: ["athena.event_dispatcher.listener"])]
# Define a listener to handle authenticating requests.
# Also register it as a service and give it the proper tag for it to be automatically registered.
struct Blog::Listeners::SecurityListener
  # Define the interface to implement the required methods
  include AED::EventListenerInterface

  # Define this type as a service for DI to pick up.
  include ADI::Service

  # Specify that we want to listen on the `Request` event.
  # The value of the has represents this listener's priority;
  # the higher the value the sooner it gets executed.
  def self.subscribed_events : AED::SubscribedEvents
    AED::SubscribedEvents{
      ART::Events::Request => 10,
    }
  end

  # Define our initializer for DI to inject the user storage.
  def initialize(@user_storage : UserStorage); end

  # Define a `#call` method scoped to the `Request` event.
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
