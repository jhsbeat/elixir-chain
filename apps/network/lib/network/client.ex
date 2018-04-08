defmodule Network.Client do
  @moduledoc """
  An elixir TCP client.
  """
  alias Network.PeerTracker
  require Logger

  @doc false
  def connect(host, port) do
    Logger.info(fn ->
      "Trying to connect to P2P network on #{host}:#{port}..."
    end)

    opts = [:binary, packet: 4, active: true]

    with {:ok, socket} <- :gen_tcp.connect(to_charlist(host), port, opts) do
      {:ok, pid} = PeerTracker.add_peer(socket, :gen_tcp)
      :gen_tcp.controlling_process(socket, pid)
      {:ok, pid}
    end
  end
end
