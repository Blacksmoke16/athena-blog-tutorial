module Blog
  struct UserProcessor < Crylog::Processors::LogProcessor
    def call(message : Crylog::Message) : Nil
      user_storage = Athena::DI.get_container.get("user_storage").as(UserStorage)

      # Return early if a message was logged in a public endpoint there won't be a user in storage
      return unless user_storage.has_user?

      # Add the current user's id to all log messages
      message.extra["user_id"] = user_storage.user.id
    end
  end
end
