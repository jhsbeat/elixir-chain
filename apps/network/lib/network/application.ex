defmodule Network.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    config = Application.get_env(:network, :server)
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Network.Worker.start_link(arg)

      # A server that accepts peer's incoming connection.
      {Network.Server, config},
      # A supervisor to track connected peers.
      {Network.PeerTracker, config}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Network.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
