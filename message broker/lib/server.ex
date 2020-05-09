defmodule Server do
  use GenServer

  def start_link(port) do
    # Start 'er up
    GenServer.start_link(__MODULE__, port)
  end

  def init(port) do
    :gen_udp.open(port, [:binary, active: true])
  end

  def handle_info({:udp, _socket, _address, _port, data}, socket) do
    handle_packet(data, socket)
  end

  defp handle_packet("quit\n", socket) do
    IO.puts("Received: quit")
    :gen_udp.close(socket)
    {:stop, :normal, nil}
  end

  defp handle_packet(data, socket) do
    msg_data = Jason.decode!(data)

    case msg_data["topic"] do
      "iot" ->
        Queue.add_iot_topic(Queue, msg_data)

      "sensors" ->
        Queue.add_sensors_topic(Queue, msg_data)

      "legacy_sensors" ->
        Queue.add_legacy_sensors_topic(Queue, msg_data)
    end

    {:noreply, socket}
  end
end
