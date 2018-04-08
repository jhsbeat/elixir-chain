defmodule Network.Helpers do
  defmacro __using__(_opts) do
    quote do
      def stringify_peername(socket) do
        {:ok, {addr, port}} = :inet.peername(socket)
    
        address = 
          addr
          |> :inet_parse.ntoa()
          |> to_string()
    
        "#{address}:#{port}"
      end
    end
  end
end