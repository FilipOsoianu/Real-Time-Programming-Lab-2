defmodule Sender do
  use GenServer

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  def notify(sender) do
    GenServer.cast(sender, :notify)
  end

  @impl true
  def handle_cast(:notify, state) do
    Process.sleep(200)
    subscribers = SubscribeServer.get_subscribers(SubscribeServer)[:subscriber]
    socket = SubscribeServer.get_subscribers(SubscribeServer)[:socket]

    if Kernel.length(subscribers) > 0 do
      Enum.each(subscribers, fn subscriber ->
        message = Queue.get_messages(Queue, subscriber[:topics])
        {:ok, json} = Jason.encode(message)
        :gen_udp.send(socket, subscriber[:address], subscriber[:port], json)
      end)

      Queue.clear_queue(Queue)
    else
      {:noreply, state}
    end

    {:noreply, state}
  end
end
