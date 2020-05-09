defmodule SubscribeServer do
  def start_link(port) do
    GenServer.start_link(__MODULE__, port,  name: __MODULE__)
  end


  def get_subscribers(server)do
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
    state_data = Map.get(state, :subscriber, [])

    if !Enum.find(state_data, fn x -> x[:port] == port end) do
      state =
        Map.put(
          state,
          :subscriber,
          state_data ++ [%{:address => address, :port => port, :topic => data}]
        )
      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_call(:get_subscribers, _from, state) do
    {:reply, state, state}
  end

  # def handle_info({:update_subscriber_topic, port, topic}, state) do
  #   state_data = Map.get(state, :subscriber, [])

  #   if Enum.find(state_data, fn x -> x[:port] == port end) do
  #     x[:topic] = topic

  #     Map.put(
  #       state,
  #       :subscriber,
  #       state_data
  #     )

  #     IO.inspect(state)
  #     {:noreply, state}
  #   end

  #   {:noreply, state}
  # end
end
