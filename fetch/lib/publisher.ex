defmodule Publisher do
  use GenServer, restart: :permanent

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg, name: __MODULE__)
  end

  @impl true
  def init(state) do
    opts = [:binary, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 6666, opts)
    {:ok, socket}
  end

  @impl true
  def handle_cast({:data, data}, state) do
    IO.inspect(data)
    # data_encode = Poison.encode!(data)
    :gen_tcp.send(state, data)
    {:noreply, state}
  end
end
