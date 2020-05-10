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

  def add_data_to_topic(queue, data) do
    GenServer.cast(queue, {:add_data, data})
  end

  def clear_queue(queue, topic) do
    GenServer.cast(queue, {:clear_topic_queue, topic})
  end

  @impl true
  def handle_cast({:add_data, publisher_data}, state) do
    topic = publisher_data["topic"]
    topic_atom = String.to_atom(topic)

    state_data = Map.get(state, topic_atom, [])
    state = Map.put(state, topic_atom, state_data ++ [publisher_data])
    Sender.send_data_to_subscribers(Sender, state)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:clear_topic_queue, topic}, state) do
    state = Map.replace!(state, topic, [])
    {:noreply, state}
  end
end
