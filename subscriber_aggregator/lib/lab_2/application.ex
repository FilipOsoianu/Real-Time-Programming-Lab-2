defmodule Lab2.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      %{
        id: Subscriber,
        start: {Subscriber, :start_link, [[6668 | 6667]]}
      }
    ]

    opts = [strategy: :one_for_one, name: KVServer.Supervisor]
    Supervisor.start_link(children, opts)

    receive do
    end
  end
end
