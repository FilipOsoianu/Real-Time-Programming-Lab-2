defmodule Subscriber do
  use GenServer

  def start_link(ports) do
    GenServer.start_link(__MODULE__, ports, name: __MODULE__)
  end

  def init(ports) do
    [subscriber_port | server_port] = ports
    {:ok, socket} = :gen_udp.open(subscriber_port, [:binary, active: true])

    topics_map = %{
      :topics => [:iot, :sensors, :legacy_sensors]
    }

    {:ok, topics_json} = Jason.encode(topics_map)

    :gen_udp.send(socket, {127, 0, 0, 1}, server_port, topics_json)

    {:ok, socket}
  end

  def handle_info({:udp, _socket, address, port, data}, socket) do
    msg_data = Jason.decode!(data)
    Aggregator.aggregate(Aggregator, msg_data, socket, address, port)
    {:noreply, socket}
  end
end
