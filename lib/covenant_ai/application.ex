defmodule CovenantAI.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CovenantAIWeb.Telemetry,
      CovenantAI.Repo,
      {DNSCluster, query: Application.get_env(:covenant_ai, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CovenantAI.PubSub},
      {AshAuthentication.Supervisor, otp_app: :covenant_ai},
      # Start a worker by calling: CovenantAI.Worker.start_link(arg)
      # {CovenantAI.Worker, arg},
      # Start to serve requests, typically the last entry
      CovenantAIWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CovenantAI.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CovenantAIWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
