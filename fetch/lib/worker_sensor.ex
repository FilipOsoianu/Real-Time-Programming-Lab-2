defmodule WorkerSensor do
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
    GenServer.cast(PublisherSensors, {:data, data})
    {:noreply, []}
  end

  @impl true
  def terminate(_reason, _state) do
    DynamicSupervisor.terminate_child(DynSupervisorSensors, self())
  end

  def json_parse(msg) do
    msg_data = Jason.decode!(msg.data)
    msg_data["message"]
  end

  defp calc_mean(data) do
    light_sensor_1 = data["light_sensor_1"]
    light_sensor_2 = data["light_sensor_2"]
    light_sensor = mean(light_sensor_1, light_sensor_2)
    unix_timestamp_us = data["unix_timestamp_100us"]

    map = %{
      :light_sensor => light_sensor,
      :unix_timestamp_us => unix_timestamp_us,
      :topic => "sensors"
    }

    {:ok, json} = Jason.encode(map)
    json
  end

  defp mean(a, b) do
    (a + b) / 2
  end
end
