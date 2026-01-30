[
  import_deps: [
    :ash,
    :ash_admin,
    :ash_authentication_phoenix,
    :ash_authentication,
    :ash_postgres,
    :ash_phoenix,
    :ecto,
    :ecto_sql,
    :phoenix,
    :reactor
  ],
  subdirectories: ["priv/*/migrations"],
  plugins: [Spark.Formatter, Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"]
]
