# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bcp,
  ecto_repos: [Bcp.Repo]

config :bcp,
  esv_api_key: System.get_env("ESV_API_KEY"),
  aws_access_key_id: System.get_env("AWS_ACCESS_KEY"),
  aws_secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY")

config :ex_aws,
  access_key_id: System.get_env("AWS_ACCESS_KEY"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  mp3_bucket: System.get_env("MP3_BUCKET")

# Configures the endpoint
config :bcp, Bcp.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ztT+LnhUMhh/z8qr2uVVCltZABVvZ48OtnSSDUrpQAc1CAzypoOiiZWHM9m9YmE3",
  render_errors: [view: Bcp.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bcp.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
