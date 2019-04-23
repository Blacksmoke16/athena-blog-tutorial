module Blog::Models
  # @[CrSerializer::ClassOptions(exclusion_policy: CrSerializer::ExclusionPolicy::ExcludeAll)]
  class User < Granite::Base
    include CrSerializer(JSON)

    adapter my_blog
    table_name "users"

    has_many articles : Article

    primary id : Int64, annotations: [
      "@[CrSerializer::Options(expose: true, readonly: true)]",
    ]

    field! first_name : String, annotations: [
      "@[CrSerializer::Options(expose: true)]",
      "@[Assert::NotBlank]",
    ]

    field! last_name : String, annotations: [
      "@[CrSerializer::Options(expose: true)]",
      "@[Assert::NotBlank]",
    ]

    field! email : String, annotations: [
      "@[CrSerializer::Options(expose: true)]",
      "@[Assert::NotBlank]",
      "@[Assert::Email(mode: CrSerializer::Assertions::EmailValidationMode::HTML5)]",
    ]

    field password : String, annotations: [
      %(@[Assert::Size(range: 8_f64..25_f64, min_message: "Your password is too short", max_message: "Your password is too long")]),
    ]

    field created_at : Time, annotations: [
      "@[CrSerializer::Options(expose: true)]",
    ]

    field updated_at : Time, annotations: [
      "@[CrSerializer::Options(expose: true)]",
    ]

    field deleted_at : Time

    before_save :hash_password

    def hash_password
      if p = @password
        @password = Crypto::Bcrypt::Password.create(p).to_s
      end
    end

    def generate_jwt : String
      JWT.encode({
        "user_id" => @id,
        "exp"     => (Time.utc_now + 1.week).to_unix,
        "iat"     => Time.utc_now.to_unix,
      },
        ENV["secret"],
        "HS512"
      )
    end
  end
end
