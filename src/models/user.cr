@[ASRA::ExclusionPolicy(:all)]
class Blog::Models::User < Granite::Base
  include ASR::Serializable
  include Assert

  connection "my_blog"
  table "users"

  has_many articles : Article

  @[ASRA::Expose]
  @[ASRA::ReadOnly]
  column id : Int64, primary: true

  @[ASRA::Expose]
  @[Assert::NotBlank]
  column first_name : String

  @[ASRA::Expose]
  @[Assert::NotBlank]
  column last_name : String

  @[ASRA::Expose]
  @[Assert::NotBlank]
  @[Assert::Email(mode: :html5)]
  column email : String

  @[ASRA::IgnoreOnSerialize]
  @[Assert::Size(Range(Int32, Int32), range: 8..25, min_message: "Your password is too short", max_message: "Your password is too long")]
  column password : String

  @[ASRA::Expose]
  @[ASRA::ReadOnly]
  column created_at : Time

  @[ASRA::Expose]
  @[ASRA::ReadOnly]
  column updated_at : Time

  column deleted_at : Time?

  before_save :hash_password

  def hash_password : Nil
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
