module Blog::Models
  @[CrSerializer::ClassOptions(exclusion_policy: CrSerializer::ExclusionPolicy::ExcludeAll)]
  class Article < Granite::Base
    include CrSerializer(JSON)

    connection my_blog
    table "articles"

    @[CrSerializer::Options(expose: true, readonly: true)]
    belongs_to user : User

    @[CrSerializer::Options(expose: true, readonly: true)]
    column id : Int64, primary: true

    @[CrSerializer::Options(expose: true)]
    @[Assert::NotBlank]
    column title : String

    @[CrSerializer::Options(expose: true)]
    @[Assert::NotBlank]
    column body : String

    @[CrSerializer::Options(expose: true, readonly: true)]
    column updated_at : Time?

    @[CrSerializer::Options(expose: true, readonly: true)]
    column created_at : Time?

    @[CrSerializer::Options(readonly: true)]
    column deleted_at : Time?
  end
end
