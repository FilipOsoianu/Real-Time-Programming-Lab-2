defmodule SubscribeServer do
  def start_link(port) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  def get_subscribers(server) do
    GenServer.call(server, :get_subscribers)
  end

  def init(port) do
    {:ok, socket} = :gen_udp.open(port, [:binary, active: true])

    map = %{
      :socket => socket,
      :subscriber => []
    }

    {:ok, map}
  end

  def handle_info({:udp, _socket, address, port, data}, state) do
    msg_data = Jason.decode!(data)
    state_data = Map.get(state, :subscriber, [])

    topics_map =
      Map.update!(msg_data, "topics", fn list -> Enum.map(list, &String.to_existing_atom/1) end)

    topics = topics_map["topics"]

    if !Enum.find(state_data, fn x -> x[:port] == port end) do
      state =
        Map.put(
          state,
          :subscriber,
          state_data ++ [%{:address => address, :port => port, :topics => topics}]
        )

      {:noreply, state}
    else
      subscriber = Enum.find(state_data, fn x -> x[:port] == port end)
      update_subscriber = Map.replace!(subscriber, :topics, topics)
      index = Enum.find_index(state_data, fn x -> x == subscriber end)
      state_data = List.replace_at(state_data, index, update_subscriber)

      state =
        Map.put(
          state,
          :subscriber,
          state_data
        )

      {:noreply, state}
    end
  end

  def handle_call(:get_subscribers, _from, state) do
    {:reply, state, state}
  end
end
