module Blog::Models
  @[CRS::ExclusionPolicy(:all)]
  class Article < Granite::Base
    include CrSerializer
    include Assert

    connection my_blog
    table "articles"

    @[CRS::Expose]
    @[CRS::ReadOnly]
    belongs_to user : User

    @[CRS::Expose]
    @[CRS::ReadOnly]
    column id : Int64, primary: true

    @[CRS::Expose]
    @[Assert::NotBlank]
    @[Assert::NotNil]
    column title : String

    @[CRS::Expose]
    @[Assert::NotBlank]
    @[Assert::NotNil]
    column body : String

    @[CRS::Expose]
    @[CRS::ReadOnly]
    column updated_at : Time?

    @[CRS::Expose]
    @[CRS::ReadOnly]
    column created_at : Time?

    @[CRS::ReadOnly]
    column deleted_at : Time?
  end
end
