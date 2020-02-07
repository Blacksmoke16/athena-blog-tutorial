module Blog::Models
  @[CRS::ExclusionPolicy(:all)]
  class User < Granite::Base
    include CrSerializer
    include Assert

    connection my_blog
    table "users"

    has_many articles : Article

    @[CRS::Expose]
    @[CRS::ReadOnly]
    column id : Int64, primary: true

    @[CRS::Expose]
    @[Assert::NotBlank]
    column first_name : String

    @[CRS::Expose]
    @[Assert::NotBlank]
    column last_name : String

    @[CRS::Expose]
    @[Assert::NotBlank]
    @[Assert::Email(mode: :html5)]
    column email : String

    @[CRS::IgnoreOnSerialize]
    @[Assert::Size(Range(Int32, Int32), range: 8..25, min_message: "Your password is too short", max_message: "Your password is too long")]
    column password : String

    @[CRS::Expose]
    column created_at : Time

    @[CRS::Expose]
    column updated_at : Time

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
