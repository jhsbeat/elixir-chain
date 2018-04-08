defmodule Network.ServerProtocol do
  @moduledoc """
  A simple TCP protocol handler that echoes all messages received.
  """
  use Network.Helpers
  alias Network.PeerTracker
  require Logger

  @behaviour :ranch_protocol
  
  # Client

  @doc """
  Starts the handler with `:proc_lib.spawn_link/3`.

  start_link/4 is a behaviour of :ranch_protocol.
  """
  def start_link(ref, socket, transport, opts) do
    Logger.debug(fn ->
      "Network.Handler.start_link(#{inspect(ref)}, #{inspect(socket)}, #{inspect(transport)}, #{inspect(opts)})"
    end)
    peername = stringify_peername(socket)
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, socket, transport, peername])
    {:ok, pid}
  end

  @doc """
  Initiates the handler, acknowledging the connection was accepted.
  Finally it makes the existing process into a `:gen_server` process and
  enters the `:gen_server` receive loop with `:gen_server.enter_loop/3`.
  """
  def init(ref, socket, transport, peername) do

    Logger.info(fn ->
      "Peer #{peername} connecting..."
    end)

    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [{:active, true}])

    {:ok, pid} = PeerTracker.add_peer(socket, transport)

    :ranch_tcp.controlling_process(socket, pid)
  end

end