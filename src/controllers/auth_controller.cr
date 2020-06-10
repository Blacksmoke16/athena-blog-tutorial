class Blog::Controllers::AuthController < ART::Controller
  # Type hinting an action argument to `HTTP::Request` will supply the current request object.
  @[ART::Post("login")]
  def login(request : HTTP::Request) : ART::Response
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

    # If an `ART::Response` is returned then it is used as is for the response,
    # otherwise, like the other endpoints, the response value is by default JSON serialized
    ART::Response.new({token: user.generate_jwt}.to_json, headers: HTTP::Headers{"content-type" => "application/json"})
  end

  private def handle_invalid_auth_credentials : Nil
    # Raise a 401 error if values are missing, or are invalid;
    # this also handles setting an appropiate www-authenticate header
    raise ART::Exceptions::Unauthorized.new "Invalid username and/or password", "Basic realm=\"My Blog\""
  end
end
