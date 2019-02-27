module Blog::Controllers
  abstract struct CorsController < Athena::Routing::StructController
    @[Athena::Routing::Callback(event: Athena::Routing::CallbackEvents::OnResponse)]
    def self.set_cors(context : HTTP::Server::Context) : Nil
      context.response.headers.add "Access-Control-Allow-Origin", "*"
    end
  end
end
