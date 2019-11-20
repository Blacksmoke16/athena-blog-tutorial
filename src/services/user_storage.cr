module Blog
  @[Athena::DI::Register]
  class UserStorage < Athena::DI::ClassService
    # Use a ! property since they'll always be a user defined in our use case
    property! user : Blog::Models::User
  end
end
