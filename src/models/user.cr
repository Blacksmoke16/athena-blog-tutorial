module Blog::Models
  @[CrSerializer::ClassOptions(exclusion_policy: CrSerializer::ExclusionPolicy::ExcludeAll)]
  class User < Granite::Base
    include CrSerializer(JSON)

    connection my_blog
    table "users"

    has_many articles : Article

    @[CrSerializer::Options(expose: true, readonly: true)]
    column id : Int64, primary: true

    @[CrSerializer::Options(expose: true)]
    @[Assert::NotBlank]
    column first_name : String

    @[CrSerializer::Options(expose: true)]
    @[Assert::NotBlank]
    column last_name : String

    @[CrSerializer::Options(expose: true)]
    @[Assert::NotBlank]
    @[Assert::Email(mode: CrSerializer::Assertions::EmailValidationMode::HTML5)]
    column email : String

    @[Assert::Size(range: 8_f64..25_f64, min_message: "Your password is too short", max_message: "Your password is too long")]
    column password : String

    @[CrSerializer::Options(expose: true)]
    column created_at : Time?

    @[CrSerializer::Options(expose: true)]
    column updated_at : Time?

    column deleted_at : Time?

    before_save :hash_password

    def hash_password
      if p = @password
        @password = Crypto::Bcrypt::Password.create(p).to_s
      end
    end

    def generate_jwt : String
      JWT.encode({
        "user_id" => @id,
        "exp"     => (Time.utc + 1.week).to_unix,
        "iat"     => Time.utc.to_unix,
      },
        ENV["SECRET"],
        :hs512
      )
    end
  end
end
