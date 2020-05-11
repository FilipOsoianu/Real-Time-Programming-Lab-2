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
    IO.inspect(data)

    {:noreply, state}
  end

end
