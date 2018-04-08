defmodule Network.Peer do
  @moduledoc """
  A GenServer that handles a peer's connection and communication in/out.

  use GenServer, restart: :temporary: 
    the child process is never restarted, regardless of the supervision strategy.
  """
  use GenServer, restart: :temporary
  require Logger

  def start_link(a, args) do
    Logger.debug(fn ->
      "Network.Peer.start_link(#{inspect(a)}, #{inspect(args)})"
    end)

    GenServer.start_link(__MODULE__, args)
  end

  def init(socket: socket, transport: transport, peername: peername) do
    Logger.debug(fn ->
      "Network.Peer.init(#{inspect(socket)}, #{inspect(transport)}, #{peername})"
    end)

    {:ok, %{socket: socket, transport: transport, peername: peername}}
  end

  def send_message(pid, message) do
    Logger.debug(fn ->
      "Network.Peer.send_message(#{inspect(pid)}, #{inspect(message)})"
    end)

    GenServer.call(pid, {:send_message, message})
  end

  # Server 

  def handle_call({:send_message, message}, _, %{socket: socket, transport: transport} = state) do
    Logger.info(fn ->
      "Sending message #{inspect(message)} to #{inspect(socket)}"
    end)

    # Send the message
    transport.send(socket, message)

    {:reply, :ok, state}
  end

  def handle_info(
        {:tcp, _, message},
        %{socket: _socket, transport: _transport, peername: peername} = state
      ) do
    Logger.info(fn ->
      "Received a new message from #{peername}: #{inspect(message)}."
    end)

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, %{peername: peername} = state) do
    Logger.info(fn ->
      "Peer #{peername} disconnected"
    end)

    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, _, reason}, %{peername: peername} = state) do
    Logger.info(fn ->
      "Error with peer #{peername}: #{inspect(reason)}"
    end)

    {:stop, :normal, state}
  end
end
