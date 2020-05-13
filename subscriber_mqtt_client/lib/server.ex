defmodule Subscriber do
  use GenServer

  def start_link(ports) do
    GenServer.start_link(__MODULE__, ports, name: __MODULE__)
  end

  def init(ports) do
    [subscriber_port | server_port] = ports
    {:ok, socket} = :gen_udp.open(subscriber_port, [:binary, active: true])

    topics_map = %{
      :topics => [:joined_messages]
    }

    {:ok, topics_json} = Jason.encode(topics_map)

    :gen_udp.send(socket, {127, 0, 0, 1}, server_port, topics_json)

    {:ok, socket}
  end

  def handle_info({:udp, _socket, _address, _port, data}, socket) do

    msg_data = Jason.decode!(data)
    Mqtt.publish_mqtt(Mqtt, msg_data)
    {:noreply, socket}
  end
end