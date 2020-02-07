@[ADI::Register]
class Blog::UserStorage
  include ADI::Service

  # Use a ! property since they'll always be a user defined in our use case.
  #
  # It also provides a `user?` getter in cases where it might not be.
  property! user : Blog::Models::User
end
