module Blog::Controllers
  struct UserController < CorsController
    @[Athena::Routing::Post(path: "user")]
    @[Athena::Routing::ParamConverter(param: "body", id_type: Int64, type: Blog::Models::User, converter: RequestBody)]
    def self.new_user(body : Blog::Models::User) : Blog::Models::User
      raise Athena::Routing::Exceptions::ConflictException.new "A user with this email already exists" if User.find_by email: body.email
      body.save
      body
    end
  end
end