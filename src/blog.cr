# Register an adapter to connect to our DB
Granite::Connections << Granite::Adapter::Pg.new(name: "my_blog", url: "postgres://blog_user:mYAw3s0meB!log@localhost:5432/blog?currentSchema=blog")

# Require some standard library things we'll need
require "crypto/bcrypt/password"

# Require our ORM and DB adapter
require "granite"
require "granite/adapter/pg"

# Require Athena
require "athena/routing"

# Require Athena's granite extension
require "athena/routing/ext/granite"

# Require JWT shard
require "jwt"

# Require our models
require "./models/*"

# Require our controllers
require "./controllers/*"

require "./middleware/*"
require "./services/*"
require "./logger/*"

module Blog
  VERSION = "0.1.0"

  # Include our models into the main module
  include Models
  include Controllers

  def Athena.configure_logger
    # Create the logs dir if it doesn't exist already.
    Dir.mkdir Athena.logs_dir unless Dir.exists? Athena.logs_dir

    Crylog.configure do |registry|
      registry.register "main" do |logger|
        handlers = [] of Crylog::Handlers::LogHandler

        if Athena.environment == "development"
          # Log to STDOUT and development log file if in develop env
          handlers << Crylog::Handlers::IOHandler.new(STDOUT)
          handlers << Crylog::Handlers::IOHandler.new(File.open("#{Athena.logs_dir}/development.log", "a"))
        elsif Athena.environment == "production"
          # Log warnings and higher to production log file if in production env.
          handlers << Crylog::Handlers::IOHandler.new(File.open("#{Athena.logs_dir}/production.log", "a"))
        end

        logger.processors = [Blog::UserProcessor.new] of Crylog::Processors::LogProcessors

        logger.handlers = handlers
      end
    end
  end

  Athena::Routing.run(
    handlers: [
      SecurityHandler.new,
      Athena::Routing::Handlers::CorsHandler.new,
      Athena::Routing::Handlers::ActionHandler.new,
    ] of HTTP::Handler
  )
end
