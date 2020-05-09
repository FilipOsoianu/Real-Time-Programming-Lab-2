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
    {:ok, json} = Jason.encode(data)
    
    Enum.each(subscribers, fn x ->
        :gen_udp.send(socket, x[:address], x[:port], json)
    end)
    {:noreply, state}
  end
end
