defmodule Mqtt do
  use GenServer

  def start_link(port) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  def publish_mqtt(mqqt, message) do
    GenServer.cast(mqqt, {:publish_mqtt, message})
  end

  @impl true
  def init(port) do
    {:ok, socket} = :gen_tcp.connect('localhost', port, [:binary, active: false, packet: :raw])
    connect(socket)
    {:ok, socket}
  end

  @impl true
  def handle_cast({:publish_mqtt, data}, state) do
    forecast_list_of_maps = data["joined_messages"]

    if forecast_list_of_maps != nil && Kernel.length(forecast_list_of_maps) > 1 do
      mean = mean(forecast_list_of_maps)

      message = Jason.encode!(mean)
      publish(state, "topic", message)
    end

    {:noreply, state}
  end

  def connect(socket) do
    connection_packet = %{
      protocol: "MQTT",
      protocol_version: 0b00000100,
      user_name: nil,
      password: nil,
      clean_session: true,
      keep_alive: 60,
      client_id: "jora",
      will: nil
    }

    # prepare packet for connection
    data = [
      encode(1, 0),
      variable_length_encode([
        protocol_header(connection_packet.protocol, connection_packet.protocol_version),
        connection_flags(connection_packet),
        keep_alive(connection_packet),
        payload(connection_packet)
      ])
    ]

    # send data for connection
    :gen_tcp.send(socket, data)
    # recv ack from connect
    {:ok, packet} = :gen_tcp.recv(socket, 0)
    <<_, _, _, return_code>> = packet

    if return_code == 0 do
      IO.inspect("Connected to mosquitto. Received return code #{return_code}")
    else
      IO.inspect("Connection error. Return code #{return_code}")
    end
  end

  def publish(socket, topic, message) do

    <<flags::4>> = <<0::1, 0::integer-size(2), 0::1>>
    length_prefix = <<byte_size(topic)::big-integer-size(16)>>
    data_publish = [encode(3, flags), variable_length_encode([[length_prefix, topic], message])]
    IO.inspect(data_publish)

    :gen_tcp.send(socket, data_publish)
  end

  defp variable_length_encode(data) when is_list(data) do
    length_prefix = data |> IO.iodata_length() |> remaining_length()
    length_prefix ++ data
  end

  defp encode(opcode, flags) do
    # convert to bitstring 
    <<opcode::4, flags::4>>
  end

  defp protocol_header(protocol, version) do
    [length_encode(protocol), version]
  end

  defp length_encode(data) do
    length_prefix = <<byte_size(data)::big-integer-size(16)>>
    [length_prefix, data]
  end

  defp connection_flags(data) do
    <<
      flag(data.user_name)::integer-size(1),
      flag(data.password)::integer-size(1),
      # will retain
      flag(0)::integer-size(1),
      # will qos
      0::integer-size(2),
      # will flag
      flag(0)::integer-size(1),
      flag(data.clean_session)::integer-size(1),
      # reserved bit
      0::1
    >>
  end

  defp flag(f) when f in [0, nil, false], do: 0

  defp flag(_), do: 1

  defp keep_alive(f) do
    <<f.keep_alive::big-integer-size(16)>>
  end

  defp payload(f) do
    [f.client_id, f.user_name, f.password]
    |> Enum.filter(&is_binary/1)
    |> Enum.map(&length_encode/1)
  end

  @highbit 0b10000000
  defp remaining_length(n) when n < @highbit, do: [<<0::1, n::7>>]

  defp remaining_length(n) do
    [<<1::1, rem(n, @highbit)::7>>] ++ remaining_length(div(n, @highbit))
  end

  defp mean(forecast_list_of_maps) do
    Enum.reduce(forecast_list_of_maps, fn forecast, acc ->
      forecast = Map.delete(forecast, "topic")
      forecast = Map.delete(forecast, "unix_timestamp_100us")
      acc = Map.delete(acc, "topic")
      acc = Map.delete(acc, "unix_timestamp_100us")

      Map.merge(forecast, acc, fn _k, v1, v2 ->
        (v1 + v2) / 2
      end)
    end)
  end
end
