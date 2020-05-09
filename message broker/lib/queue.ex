defmodule Queue do
  use GenServer

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg, name: __MODULE__)
  end

  @impl true
  def init(_) do
    map = %{
      :iot => [],
      :sensors => [],
      :legacy_sensors => []
    }

    {:ok, map}
  end

  def add_iot_topic(queue, data) do
    GenServer.cast(queue, {:iot, data})
  end

  def add_sensors_topic(queue, data) do
    GenServer.cast(queue, {:sensors, data})
  end

  def add_legacy_sensors_topic(queue, data) do
    GenServer.cast(queue, {:legacy_sensors, data})
  end

  @impl true
  def handle_cast({:iot, publisher_data}, state) do
    iot_data = state[:iot]

    data = %{
      iot: publisher_data["atmo_pressure_sensor"],
      wind_speed_sensor: publisher_data["wind_speed_sensor"],
      unix_timestamp_100us: publisher_data["unix_timestamp_100us"]
    }

    iot_data = [data | iot_data]

    state = %{
      :iot => iot_data,
      :sensors => state[:sensors],
      :legacy_sensors => state[:legacy_sensors]
    }

    {:noreply, state}
  end

  @impl true
  def handle_cast({:sensors, publisher_data}, state) do
    sensors_data = state[:sensors]

    data = %{
      light_sensor: publisher_data["light_sensor"],
      unix_timestamp_us: publisher_data["unix_timestamp_us"]
    }

    sensors_data = [data | sensors_data]

    state = %{
      :iot => state[:iot],
      :sensors => sensors_data,
      :legacy_sensors => state[:legacy_sensors]
    }

    {:noreply, state}
  end

  @impl true
  def handle_cast({:legacy_sensors, publisher_data}, state) do
    legacy_sensors_data = state[:legacy_sensors]

    data = %{
      humidity_sensor: publisher_data["humidity_sensor"],
      temperature_sensor: publisher_data["temperature_sensor"],
      unix_timestamp_100us: publisher_data["unix_timestamp_100us"]
    }

    legacy_sensors_data = [data | legacy_sensors_data]

    state = %{
      :iot => state[:iot],
      :sensors => state[:sensors],
      :legacy_sensors => legacy_sensors_data
    }

    {:noreply, state}
  end

  @impl true
  def handle_call({:get_messages, topic}, _from, state) do
    topic_atom = String.to_atom(topic)

    case topic_atom do
      "iot" ->
        response = state[:iot]

        state = %{
          :iot => [],
          :sensors => state[:sensors],
          :legacy_sensors => state[:legacy_sensors]
        }

        {:reply, response, state}

      "sensors" ->
        response = state[:sensors]

        state = %{
          :iot => state[:iot],
          :sensors => [],
          :legacy_sensors => state[:legacy_sensors]
        }

        {:reply, response, state}

      "legacy_sensors" ->
        response = state[:legacy_sensors]

        state = %{
          :iot => state[:iot],
          :sensors => state[:sensors],
          :legacy_sensors => []
        }

        {:reply, response, state}
    end
  end
end
