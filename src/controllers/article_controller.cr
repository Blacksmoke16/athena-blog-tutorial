@[ART::Prefix("article")]
@[ADI::Register(public: true)]
# The `ART::Prefix` annotation will add the given prefix to each route in the controller.
class Blog::Controllers::ArticleController < ART::Controller
  # Define our initializer for DI
  def initialize(@user_storage : Blog::UserStorage); end

  @[ART::Post(path: "")]
  @[ART::ParamConverter("article", converter: Blog::Converters::RequestBody, model: Blog::Models::Article)]
  def new_article(article : Blog::Models::Article) : Blog::Models::Article
    # Set the owner of the article to the currently authenticated user
    article.user = @user_storage.user
    article.save
    article
  end

  @[ART::Get(path: "")]
  def get_articles : Array(Blog::Models::Article)
    # We are also using the user in UserStorage as an additional conditional in our query when fetching articles
    # this allows us to only returns articles that belong to the current user.
    Blog::Models::Article.where(:deleted_at, :neq, nil).where(:user_id, :eq, @user_storage.user.id).select
  end

  @[ART::Put(path: "")]
  @[ART::ParamConverter("article", converter: Blog::Converters::RequestBody, model: Blog::Models::Article)]
  def update_article(article : Blog::Models::Article) : Blog::Models::Article
    # Set the owner of the article to the currently authenticated user
    article.user = @user_storage.user
    article.save
    article
  end

  @[ART::Get("/:id")]
  @[ART::ParamConverter("article", converter: Blog::Converters::DB, model: Blog::Models::Article)]
  def get_article(article : Blog::Models::Article) : Blog::Models::Article
    article
  end

  @[ART::Delete("/:id")]
  @[ART::ParamConverter("article", converter: Blog::Converters::DB, model: Blog::Models::Article)]
  def delete_article(article : Blog::Models::Article) : Nil
    article.deleted_at = Time.utc
    article.save
  end
end
