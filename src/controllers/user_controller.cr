module Blog::Controllers
  class UserController < Athena::Routing::Controller
    @[Athena::Routing::Post(path: "user")]
    @[Athena::Routing::ParamConverter(param: "body", id_type: Int64, type: Blog::Models::User, converter: Athena::Routing::Converters::RequestBody)]
    def new_user(body : Blog::Models::User) : Blog::Models::User
      raise Athena::Routing::Exceptions::ConflictException.new "A user with this email already exists" if User.find_by email: body.email
      body.save
      Athena.logger.info "New user registered", Crylog::LogContext{"user_id" => body.id, "email" => body.email, "first_name" => body.first_name, "last_name" => body.last_name}
      body
    end
  end
end
