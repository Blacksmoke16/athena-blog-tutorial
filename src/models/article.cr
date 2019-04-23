module Blog::Models
  @[CrSerializer::ClassOptions(exclusion_policy: CrSerializer::ExclusionPolicy::ExcludeAll)]
  class Article < Granite::Base
    include CrSerializer(JSON)

    adapter my_blog
    table_name "articles"

    belongs_to :user, annotations: [
      "@[CrSerializer::Options(expose: true, readonly: true)]",
    ]

    primary id : Int64, annotations: [
      "@[CrSerializer::Options(expose: true, readonly: true)]",
    ]

    field! title : String, annotations: [
      "@[CrSerializer::Options(expose: true)]",
      "@[Assert::NotBlank]",
    ]

    field! body : String, annotations: [
      "@[CrSerializer::Options(expose: true)]",
      "@[Assert::NotBlank]",
    ]

    field updated_at : Time, annotations: [
      "@[CrSerializer::Options(expose: true, readonly: true)]",
    ]

    field created_at : Time, annotations: [
      "@[CrSerializer::Options(expose: true, readonly: true)]",
    ]

    field deleted_at : Time, annotations: [
      "@[CrSerializer::Options(readonly: true)]",
    ]
  end
end
