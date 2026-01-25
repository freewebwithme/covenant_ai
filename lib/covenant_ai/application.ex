defmodule CovenantAi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CovenantAiWeb.Telemetry,
      CovenantAi.Repo,
      {DNSCluster, query: Application.get_env(:covenant_ai, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CovenantAi.PubSub},
      # Start a worker by calling: CovenantAi.Worker.start_link(arg)
      # {CovenantAi.Worker, arg},
      # Start to serve requests, typically the last entry
      CovenantAiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CovenantAi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CovenantAiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
