module Blog
  class SecurityHandler
    include HTTP::Handler

    def call(ctx : HTTP::Server::Context) : Nil
      # Allow POST user and POST login through since they are public
      # In the future Athena will most likely have a more structured way to handle auth
      if ctx.request.method == "POST" && {"/user", "/login"}.includes? ctx.request.path
        call_next ctx
        return
      end

      # Return a 401 error if the token is missing or malformed
      raise Athena::Routing::Exceptions::UnauthorizedException.new "Missing bearer token" unless (auth_header = ctx.request.headers.get?("Authorization").try &.first) && auth_header.starts_with? "Bearer "

      # Get the JWT token from the Bearer header
      token = auth_header.lchop("Bearer ")

      begin
        # Validate the token
        body = JWT.decode token, ENV["SECRET"], :hs512
      rescue decode_error : JWT::DecodeError
        # Throw a 401 error if the JWT token is invalid
        raise Athena::Routing::Exceptions::UnauthorizedException.new "Invalid token"
      end

      # Get the user storage service from the container
      user_storage = Athena::DI.get_container.get("user_storage").as(UserStorage)

      # Set the user in user storage
      user_storage.user = Blog::Models::User.find! body[0]["user_id"]

      # Call the next handler
      call_next ctx
    end
  end
end
