@[ASRA::ExclusionPolicy(:all)]
class Blog::Models::Article < Granite::Base
  include ASR::Serializable
  include Assert

  connection my_blog
  table "articles"

  @[ASRA::Expose]
  @[ASRA::ReadOnly]
  belongs_to user : User

  @[ASRA::Expose]
  @[ASRA::ReadOnly]
  column id : Int64, primary: true

  @[ASRA::Expose]
  @[Assert::NotBlank]
  @[Assert::NotNil]
  column title : String

  @[ASRA::Expose]
  @[Assert::NotBlank]
  @[Assert::NotNil]
  column body : String

  @[ASRA::Expose]
  @[ASRA::ReadOnly]
  column updated_at : Time?

  @[ASRA::Expose]
  @[ASRA::ReadOnly]
  column created_at : Time?

  @[ASRA::ReadOnly]
  column deleted_at : Time?
end
