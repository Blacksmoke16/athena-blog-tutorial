# Register an adapter to connect to our DB
Granite::Adapters << Granite::Adapter::Pg.new({name: "my_blog", url: "postgres://blog_user:mYAw3s0meB!log@localhost:5432/blog?currentSchema=blog"})

# Lets turn on the logs to see the queries being made
Granite.settings.logger = Logger.new STDOUT, Logger::DEBUG

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

# Require our middleware
require "./controllers/middleware/*"

# Require our controllers
require "./controllers/*"

module Blog
  VERSION = "0.1.0"

  # Include our models into the main module
  include Models
  include Controllers

  Athena::Routing.run
end
