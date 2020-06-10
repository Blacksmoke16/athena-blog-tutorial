@[ADI::Register]
# The ADI::Register annotation tells the DI component how this service should be registered
class Blog::UserStorage
  # Use a ! property since they'll always be a user defined in our use case.
  #
  # It also provides a `user?` getter in cases where it might not be.
  property! user : Blog::Models::User
end
