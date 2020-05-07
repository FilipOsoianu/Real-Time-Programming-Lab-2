defmodule WorkerIot do
  use GenServer, restart: :transient

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg)
  end

  @impl true
  def init(msg) do
    {:ok, msg}
  end

  @impl true
  def handle_cast({:compute, msg}, _states) do
    data = json_parse(msg)
    data = calc_mean(data)
    GenServer.cast(Publisher, {:data, data})
    {:noreply, []}
  end

  @impl true
  def terminate(_reason, _state) do
    DynamicSupervisor.terminate_child(DynSupervisorIot, self())
  end

  def json_parse(msg) do
    msg_data = Jason.decode!(msg.data)
    msg_data["message"]
  end

  defp calc_mean(data) do
    atmo_pressure_sensor_1 = data["atmo_pressure_sensor_1"]
    atmo_pressure_sensor_2 = data["atmo_pressure_sensor_2"]
    atmo_pressure_sensor = mean(atmo_pressure_sensor_1, atmo_pressure_sensor_2)
    wind_speed_sensor_1 = data["wind_speed_sensor_1"]
    wind_speed_sensor_2 = data["wind_speed_sensor_2"]
    wind_speed_sensor = mean(wind_speed_sensor_1, wind_speed_sensor_2)
    unix_timestamp_us = data["unix_timestamp_us"]

    map = %{
      :atmo_pressure_sensor => atmo_pressure_sensor,
      :wind_speed_sensor => wind_speed_sensor,
      :unix_timestamp_us => unix_timestamp_us
    }
    {:ok, json} = Jason.encode(map)
    IO.inspect(json)

    json
  end

  defp mean(a, b) do
    (a + b) / 2
  end
end
