defmodule Forecast do
  use GenServer

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg, name: __MODULE__)
  end

  def forecast(aggregator, message) do
    GenServer.cast(aggregator, {:forecast, message})
  end

  @impl true
  def init(msg) do
    {:ok, msg}
  end

  @impl true
  def handle_cast({:forecast, data}, state) do
    forecast_list_of_maps = data["joined_messages"]
    if forecast_list_of_maps != nil  && Kernel.length(forecast_list_of_maps) > 1   do
      mean = mean(forecast_list_of_maps)
      forecast = forecast(mean)
      IO.inspect(forecast)
    end

    {:noreply, state}
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

  defp forecast(data) do
    cond do
      data["temperature_sensor"] < -2 && data["light_sensor"] < 128 &&
          data["atmo_pressure_sensor"] < 720 ->
        "SNOW"

      data["temperature_sensor"] < -2 && data["light_sensor"] > 128 &&
          data["atmo_pressure_sensor"] < 680 ->
        "WET_SNOW"

      data["temperature_sensor"] < -8 ->
        "SNOW"

      data["temperature_sensor"] < -15 && data["wind_speed_sensor"] > 45 ->
        "BLIZZARD"

      data["temperature_sensor"] > 0 && data["atmo_pressure_sensor"] < 710 &&
        data["humidity_sensor"] > 70 &&
          data["wind_speed_sensor"] < 20 ->
        "SLIGHT_RAIN"

      data["temperature_sensor"] > 0 && data["atmo_pressure_sensor"] < 690 &&
        data["humidity_sensor"] > 70 &&
          data["wind_speed_sensor"] > 20 ->
        "HEAVY_RAIN"

      data["temperature_sensor"] > 30 && data["atmo_pressure_sensor"] < 770 &&
        data["humidity_sensor"] > 80 &&
          data["light_sensor"] > 192 ->
        "HOT"

      data["temperature_sensor"] > 30 && data["atmo_pressure_sensor"] < 770 &&
        data["humidity_sensor"] > 50 &&
        data["light_sensor"] > 192 && data["wind_speed_sensor"] > 35 ->
        "CONVECTION_OVEN"

      data["temperature_sensor"] > 25 && data["atmo_pressure_sensor"] < 750 &&
        data["humidity_sensor"] > 70 &&
        data["light_sensor"] < 192 && data["wind_speed_sensor"] < 10 ->
        "CONVECTION_OVEN"

      data["temperature_sensor"] > 25 && data["atmo_pressure_sensor"] < 750 &&
        data["humidity_sensor"] > 70 &&
        data["light_sensor"] < 192 && data["wind_speed_sensor"] > 10 ->
        "SLIGHT_BREEZE"

      data["light_sensor"] < 128 ->
        "CLOUDY"

      data["temperature_sensor"] > 30 && data["atmo_pressure_sensor"] < 660 &&
        data["humidity_sensor"] > 85 &&
          data["wind_speed_sensor"] > 45 ->
        "MONSOON"

      true ->
        "JUST_A_NORMAL_DAY"
    end
  end
end
