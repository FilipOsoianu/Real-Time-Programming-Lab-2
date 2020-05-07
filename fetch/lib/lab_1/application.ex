defmodule Lab1.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: DataFlowIot,
        start: {DataFlowIot, :start_link, [""]}
      },
      %{
        id: DataFlowSensors,
        start: {DataFlowSensors, :start_link, [""]}
      },
      %{
        id: DataFlowLegacy,
        start: {DataFlowLegacy, :start_link, [""]}
      },
      %{
        id: Router,
        start: {Router, :start_link, [""]}
      },
      {
        DynSupervisorIot,
        []
      },
      {
        DynSupervisorSensors,
        []
      },
      {
        DynSupervisorLegacy,
        []
      },
      %{
        id: RequestSensors,
        start: {RequestSensors, :start_link, ["http://localhost:4000/sensors"]}
      },
      %{
        id: RequestIot,
        start: {RequestIot, :start_link, ["http://localhost:4000/iot"]}
      },
      %{
        id: RequestLegacy,
        start: {RequestLegacy, :start_link, ["http://localhost:4000/legacy_sensors"]}
      },
      %{
        id: Publisher,
        start: {Publisher, :start_link, [""]}
      }
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)

    receive do
    end
  end
end
