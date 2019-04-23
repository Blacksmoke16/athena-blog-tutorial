module Blog::Controllers
  abstract class SecurityController < Athena::Routing::Controller
    getter current_user : Blog::Models::User

    def initialize(ctx : HTTP::Server::Context) : Nil
      # Return a 401 error if the token is missing or malformed
      raise Athena::Routing::Exceptions::UnauthorizedException.new "Missing bearer token" unless (auth_header = ctx.request.headers.get?("Authorization").try &.first) && auth_header.starts_with? "Bearer "

      # Get the JWT token from the Bearer header
      token = auth_header.lchop("Bearer ")

      begin
        # Validate the token
        body = JWT.decode token, ENV["secret"], "HS512"
      rescue decode_error : JWT::DecodeError
        # Throw a 401 error if the JWT token is invalid
        raise Athena::Routing::Exceptions::UnauthorizedException.new "Invalid token"
      end

      # Set the current user
      @current_user = Blog::Models::User.find! body[0]["user_id"]

      # Call the parent controller initializer to set the request context.
      super
    end
  end
end
