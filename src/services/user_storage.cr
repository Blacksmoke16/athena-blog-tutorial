module Blog
  @[Athena::DI::Register]
  class UserStorage < Athena::DI::ClassService
    property! user : Blog::Models::User

    def has_user? : Bool
      !!@user
    end
  end
end
