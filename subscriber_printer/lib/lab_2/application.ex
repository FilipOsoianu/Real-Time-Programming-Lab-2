defmodule Lab2.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: Subscriber,
        start: {Subscriber, :start_link, [[6610 | 6667]]}
      },
      %{
        id: Printer,
        start: {Printer, :start_link, [""]}
      }
    ]

    opts = [strategy: :one_for_one, name: KVServer.Supervisor]
    Supervisor.start_link(children, opts)

    receive do
    end
  end
end
