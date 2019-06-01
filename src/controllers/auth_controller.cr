module Blog::Controllers
  class AuthController < Athena::Routing::Controller
    @[Athena::Routing::Post(path: "login")]
    def login(body : HTTP::Params) : NamedTuple(token: String)
      # Find a user with the given ID
      user = Blog::Models::User.find_by email: body["email"]

      # Raise a 401 error if either a user isn't found or the password does not match
      raise Athena::Routing::Exceptions::UnauthorizedException.new "Invalid username and/or password" if !user || !(Crypto::Bcrypt::Password.new(user.password!) == body["password"])

      Athena.logger.info "User logged in", Crylog::LogContext{"user_id" => user.id}

      {token: user.generate_jwt}
    end
  end
end
