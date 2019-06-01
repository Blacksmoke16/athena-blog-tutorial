module Blog::Controllers
  @[Athena::Routing::ControllerOptions(prefix: "article")]
  class ArticleController < Athena::Routing::Controller
    include Athena::DI::Injectable

    def initialize(@request_stack : Athena::Routing::RequestStack, @user_storage : UserStorage); end

    @[Athena::Routing::Post(path: "")]
    @[Athena::Routing::ParamConverter(param: "body", type: Blog::Models::Article, converter: RequestBody)]
    def new_article(body : Blog::Models::Article) : Blog::Models::Article
      # Sets the owner of the blog post as the current authed user
      body.user = @user_storage.user
      body.save
      Athena.logger.info "Article ##{body.id} was created"
      body
    end

    @[Athena::Routing::Get(path: "")]
    def get_articles : Array(Blog::Models::Article)
      Athena.logger.info "Fetching articles"
      Blog::Models::Article.where(:deleted_at, :neq, nil).where(:user_id, :eq, @user_storage.user.id).select
    end

    @[Athena::Routing::Put(path: "")]
    @[Athena::Routing::ParamConverter(param: "body", type: Blog::Models::Article, converter: RequestBody)]
    def update_article(body : Blog::Models::Article) : Blog::Models::Article
      body.user = @user_storage.user
      body.save
      Athena.logger.info "Article ##{body.id} was updated"
      body
    end

    @[Athena::Routing::Get(path: "/:article_id")]
    @[Athena::Routing::ParamConverter(param: "article", pk_type: Int64, type: Blog::Models::Article, converter: Exists)]
    def get_article(article : Blog::Models::Article) : Blog::Models::Article
      article
    end

    @[Athena::Routing::Delete(path: "/:article_id")]
    @[Athena::Routing::ParamConverter(param: "article", pk_type: Int64, type: Blog::Models::Article, converter: Exists)]
    def delete_article(article : Blog::Models::Article) : Nil
      article.deleted_at = Time.utc
      article.save
      Athena.logger.info "Article ##{article.id} was deleted"
      @request_stack.response.status = HTTP::Status::ACCEPTED
    end
  end
end
