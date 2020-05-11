defmodule Printer do
  use GenServer

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg, name: __MODULE__)
  end

  def printer(printer, message) do
    GenServer.cast(printer, {:printer, message})
  end

  @impl true
  def init(msg) do
    {:ok, msg}
  end

  @impl true
  def handle_cast({:printer, data}, state) do
    forecast_list_of_maps = data["joined_messages"]
    if forecast_list_of_maps != nil  && Kernel.length(forecast_list_of_maps) > 1   do
      mean = mean(forecast_list_of_maps)
       printer(mean)
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

  defp printer(data) do
      IO.puts("<------------------------------->")
      IO.puts("Atmosphere pressure ")
      IO.inspect(data["atmo_pressure_sensor"])
      IO.puts("Humidity")
      IO.inspect(data["humidity_sensor"])
      IO.puts("Light")
      IO.inspect(data["light_sensor"])
      IO.puts("Temperature")
      IO.inspect(data["temperature_sensor"])
      IO.puts("Wind speed")
      IO.inspect(data["wind_speed_sensor"])
      IO.puts("<------------------------------->")
  end
end
