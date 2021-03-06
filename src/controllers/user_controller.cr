class Blog::Controllers::UserController < ART::Controller
  @[ART::Post("user")]
  @[ART::View(status: :created)]
  @[ART::ParamConverter("user", converter: Blog::Converters::RequestBody, model: Blog::Models::User)]
  def new_user(user : Blog::Models::User) : Blog::Models::User
    raise ART::Exceptions::Conflict.new "A user with this email already exists." if User.exists? email: user.email
    user.save
    user
  end
end
