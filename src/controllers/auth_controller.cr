class Blog::Controllers::AuthController < ART::Controller
  @[ART::Post(path: "login")]
  def login(request : HTTP::Request) : NamedTuple(token: String)
    # Raise an exception if there is no request body
    raise ART::Exceptions::BadRequest.new "Missing request body" unless body = request.body

    # Parse the request body into an HTTP::Params object
    form_data = HTTP::Params.parse body.gets_to_end

    # Handle missing form values
    handle_invalid_auth_credentials unless email = form_data["email"]?
    handle_invalid_auth_credentials unless password = form_data["password"]?

    # Find a user with the given ID
    user = Blog::Models::User.find_by email: email

    # Raise a 401 error if either a user isn't found or the password does not match
    handle_invalid_auth_credentials if !user || !(Crypto::Bcrypt::Password.new(user.password).verify password)

    # Return the token
    {token: user.generate_jwt}
  end

  private def handle_invalid_auth_credentials : Nil
    raise ART::Exceptions::Unauthorized.new "Bearer realm=\"My Blog\"", "Invalid username and/or password"
  end
end
