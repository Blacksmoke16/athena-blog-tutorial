# Register an adapter to connect to our DB
Granite::Connections << Granite::Adapter::Pg.new(name: "my_blog", url: "postgres://blog_user:mYAw3s0meB!log@localhost:5432/blog?currentSchema=blog")

# Require some standard library things we'll need
require "crypto/bcrypt/password"

# Require our ORM and DB adapter
require "granite"
require "granite/adapter/pg"

# Require Athena
require "athena"

# This will eventually be replaced by Athena's serializer component
require "CrSerializer"

# This will eventually be replaced by Athena's validation component
require "assert"

# Require JWT shard
require "jwt"

# Require our models
require "./models/*"

# Require our controllers
require "./controllers/*"
require "./converters/*"
require "./listeners/*"
require "./services/*"

module Blog
  VERSION = "0.8.0"

  # Include our models into the main module
  include Models
  include Controllers

  ART.run
end
