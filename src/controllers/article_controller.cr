module Blog::Controllers
  @[Athena::Routing::ControllerOptions(prefix: "article")]
  struct ArticleController < SecurityController
    @[Athena::Routing::Post(path: "")]
    @[Athena::Routing::ParamConverter(param: "body", type: Blog::Models::Article, converter: RequestBody)]
    def self.new_article(body : Blog::Models::Article) : Blog::Models::Article
      # Sets the owner of the blog post as the current authed user
      body.user = current_user
      body.save
      body
    end

    @[Athena::Routing::Get(path: "")]
    def self.get_articles : Array(Blog::Models::Article)
      Blog::Models::Article.where(:deleted_at, :neq, nil).where(:user_id, :eq, current_user.id).select
    end

    @[Athena::Routing::Put(path: "")]
    @[Athena::Routing::ParamConverter(param: "body", type: Blog::Models::Article, converter: RequestBody)]
    def self.update_article(body : Blog::Models::Article) : Blog::Models::Article
      body.user = current_user
      body.save
      body
    end

    @[Athena::Routing::Get(path: "/:article_id")]
    @[Athena::Routing::ParamConverter(param: "article", pk_type: Int64, type: Blog::Models::Article, converter: Exists)]
    def self.get_article(article : Blog::Models::Article) : Blog::Models::Article
      article
    end

    @[Athena::Routing::Delete(path: "/:article_id")]
    @[Athena::Routing::ParamConverter(param: "article", pk_type: Int64, type: Blog::Models::Article, converter: Exists)]
    def self.delete_article(article : Blog::Models::Article) : Nil
      article.deleted_at = Time.utc_now
      article.save
    end
  end
end
