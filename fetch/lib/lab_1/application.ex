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
        id: PublisherIot,
        start: {PublisherIot, :start_link, [[6661 | 6666]]}
      },
      %{
        id: PublisherSensors,
        start: {PublisherSensors, :start_link, [[6662 | 6666]]}
      },
      %{
        id: PublisherLegacy,
        start: {PublisherLegacy, :start_link, [[6663 | 6666]]}
      }
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)

    receive do
    end
  end
end
