defmodule PublisherIot do
  use GenServer, restart: :permanent

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg, name: __MODULE__)
  end

  @impl true
  def init(state) do
    [publisher_port | server_port] = state
    {:ok, socket} = :gen_udp.open(publisher_port)
    state = [server_port | socket]
    {:ok, state}
  end

  @impl true
  def handle_cast({:data, data}, state) do
    [server_port | socket] = state
    :gen_udp.send(socket, {127, 0, 0, 1}, server_port, data)
    {:noreply, state}
  end
end
