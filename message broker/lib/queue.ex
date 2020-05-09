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
  def handle_call({:get_messages, topic}, _from, state) do
    topic_atom = String.to_atom(topic)
    response = state[topic_atom]
    state = Map.put(state, topic_atom, [])
    IO.inspect(state)
    {:reply, response, state}
  end


end
