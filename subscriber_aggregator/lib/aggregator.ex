defmodule Aggregator do
  use GenServer

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg, name: __MODULE__)
  end

  def aggregate(aggregator, message) do
    GenServer.cast(aggregator, {:aggregate, message})
  end

  @impl true
  def init(msg) do
   
    {:ok, msg}
  end

  @impl true
  def handle_cast({:aggregate, data}, state) do
    iot_messages = data["iot"]
    sensors_messages = data["sensors"]
    legacy_sensors_messages = data["legacy_sensors"]

    joined_list = join_sensors(iot_messages, sensors_messages, legacy_sensors_messages)
    if Kernel.length(joined_list)>0 do
      IO.inspect(joined_list)
    end
    {:noreply, state}
  end



  defp join_sensors(list_iot, list_sensors, list_legacy_sensors) do

    joined_list = Enum.map(list_iot, fn iot_msg ->
      iot_timestamp = iot_msg["unix_timestamp_100us"]

      sensors_msg = Enum.find(list_sensors, fn sensors_msg ->
        sensors_timestamp = sensors_msg["unix_timestamp_100us"]
        (iot_timestamp - sensors_timestamp <= 100) &&
        (iot_timestamp - sensors_timestamp >= -100)
      end)

      legacy_sensors_msg = Enum.find(list_legacy_sensors, fn legacy_sensors_msg ->
        legacy_sensors_timestamp = legacy_sensors_msg["unix_timestamp_100us"]
        (iot_timestamp - legacy_sensors_timestamp <= 100) &&
        (iot_timestamp - legacy_sensors_timestamp >= -100)
      end)

      if sensors_msg != nil && legacy_sensors_msg != nil do
        %{
          "atmo_pressure_sensor" => iot_msg["atmo_pressure_sensor"],
          "wind_speed_sensor" => iot_msg["wind_speed_sensor"],
          "humidity_sensor" => legacy_sensors_msg["humidity_sensor"],
          "temperature_sensor" => legacy_sensors_msg["temperature_sensor"],
          "light_sensor" => sensors_msg["light_sensor"],
          "unix_timestamp_100us" => iot_msg["unix_timestamp_100us"]
        }
      end
    end)
    Enum.filter(joined_list, fn x -> x != nil end)
  end
end
