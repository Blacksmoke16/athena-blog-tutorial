module Blog::Controllers
  abstract struct SecurityController < Athena::Routing::Controller
    class_getter current_user : Blog::Models::User = Blog::Models::User.new # Set to new instance to prevent nil values

    @[Athena::Routing::Callback(event: Athena::Routing::CallbackEvents::OnRequest)]
    def self.authenticate(context : HTTP::Server::Context) : Nil
      # Return a 401 error if the token is missing or malformed
      raise Athena::Routing::Exceptions::UnauthorizedException.new "Missing bearer token" unless (auth_header = context.request.headers.get?("Authorization").try &.first) && auth_header.starts_with? "Bearer "

      # Get the JWT token from the Bearer header
      token = auth_header.lchop("Bearer ")

      # Validate the token
      body = JWT.decode token, ENV["secret"], "HS512"

      # Set the current user
      @@current_user = Blog::Models::User.find! body[0]["user_id"]
    rescue decode_error : JWT::DecodeError
      # Throw a 401 error if the JWT token is invalid
      raise Athena::Routing::Exceptions::UnauthorizedException.new "Invalid token"
    end
  end
end
