defmodule Network.Server do
  @moduledoc """
  An elixir TCP server.
  """
  use GenServer
  alias Network.Handler
  require Logger

  @doc """
  Starts the server.
  """
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end
  
  @doc """
  Initiate the listener (socket accpetor pool).
  """
  def init(port: port) do
    opts = [{:port, port}]

    # start_listener(Ref, Transport, TransOpts, Protocol, ProtoOpts)
    {:ok, pid} = :ranch.start_listener(:network, :ranch_tcp, opts, Handler, [])

    Logger.info(fn ->
      "Listening for connections on port #{port}"
    end)

    {:ok, pid}
  end
end