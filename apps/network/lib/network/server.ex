defmodule Network.Server do
  @moduledoc """
  An elixir TCP server.
  """
  use GenServer
  alias Network.ServerProtocol
  require Logger

  @doc """
  Starts the server.
  """
  def start_link(args) do
    Logger.debug(fn ->
      "Network.Server.start_link(#{inspect(args)})"
    end)

    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Initiate the listener (socket accpetor pool).
  """
  def init(port: port) do
    Logger.debug(fn ->
      "Network.Server.init(port: #{port})"
    end)

    opts = [{:port, port}]

    # start_listener(Ref, Transport, TransOpts, Protocol, ProtoOpts)
    {:ok, pid} = :ranch.start_listener(:network, :ranch_tcp, opts, ServerProtocol, [])

    Logger.info(fn ->
      "Listening for connections on port #{port}"
    end)

    {:ok, pid}
  end
end
