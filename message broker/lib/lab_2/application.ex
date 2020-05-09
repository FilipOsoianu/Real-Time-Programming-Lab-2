defmodule Lab2.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      %{
        id: Server,
        start: {Server, :start_link, [6666]}
      },
      %{
        id: Queue,
        start: {Queue, :start_link, [""]}
      }
    ]

    opts = [strategy: :one_for_one, name: KVServer.Supervisor]
    Supervisor.start_link(children, opts)

    receive do
    end
  end
end
