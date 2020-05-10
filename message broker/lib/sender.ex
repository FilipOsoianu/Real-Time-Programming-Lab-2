defmodule Sender do
  use GenServer

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  def send_data_to_subscribers(sender, data) do
    GenServer.cast(sender, {:send_data, data})
  end

  @impl true
  def handle_cast({:send_data, data}, state) do
    subscribers = SubscribeServer.get_subscribers(SubscribeServer)[:subscriber]
    socket = SubscribeServer.get_subscribers(SubscribeServer)[:socket]

    Enum.each(subscribers, fn x ->
      Enum.each(x[:topics], fn y ->
        if Kernel.length(data[String.to_atom(y)]) > 0 do
          {:ok, json} = Jason.encode(data[String.to_atom(y)])
          :gen_udp.send(socket, x[:address], x[:port], json)
        else
          {:noreply, state}
        end
      end)
    end)

    Queue.clear_queue(Queue)
    {:noreply, state}
  end
end
