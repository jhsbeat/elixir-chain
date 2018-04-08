defmodule Network.PeerTracker do
  @moduledoc """
  A supervisor that tracks peers connected. Each peer is a Network.Peer worker.
  """
  use Supervisor
  use Network.Helpers
  alias Network.Peer
  require Logger

  def start_link(args) do
    Logger.debug(fn ->
      "Network.PeerTracker.start_link(#{inspect(args)})"
    end)

    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    Logger.debug(fn ->
      "Network.PeerTracker.init(#{inspect(args)})"
    end)

    Supervisor.init([Peer], strategy: :simple_one_for_one)
  end

  @doc """

  """
  def add_peer(socket, transport) do
    Logger.debug(fn ->
      "Network.PeerTracker.add_peer(#{inspect(socket)}, #{inspect(transport)})"
    end)

    peername = stringify_peername(socket)

    Supervisor.start_child(__MODULE__, [
      [socket: socket, transport: transport, peername: peername]
    ])
  end

  def list_peers do
    __MODULE__
    |> Supervisor.which_children()
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end
end
