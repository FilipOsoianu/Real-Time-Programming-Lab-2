defmodule Router do
  use GenServer, restart: :permanent

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg, name: __MODULE__)
  end

  @impl true
  def init(_msg) do
    counter = 0
    {:ok, counter}
  end

  def send_event_iot(event) do
    GenServer.cast(Router, {:router_iot, event})
  end

  def send_event_sensor(event) do
    GenServer.cast(Router, {:router_sensors, event})
  end

  def send_event_legacy_sensors(event) do
    # IO.inspect(event)
    # GenServer.cast(feeder_pid, {:router_legacy_sensors, event})
  end

  @impl true
  def handle_cast({:router_iot, msg}, states) do
    counter = states
    recommend_max_workers = GenServer.call(DataFlowIot, :recommend_max_workers)
    pids_list = DynSupervisorIot.pid_children()

    if DynSupervisorIot.count_children()[:active] < recommend_max_workers do
      create_worker(DynSupervisorIot, msg)
    else
      if DynSupervisorIot.count_children()[:active] > recommend_max_workers do
        [head | _tail] = pids_list
        remove_worker(DynSupervisorIot, head)
      end
    end

    if counter < length(pids_list) do
      counter = counter + 1
      compute_forecast(DynSupervisorIot, pids_list, counter, msg)
      {:noreply, counter}
    else
      counter = 0
      compute_forecast(DynSupervisorIot, pids_list, counter, msg)
      {:noreply, counter}
    end
  end

  @impl true
  def handle_cast({:router_sensors, msg}, states) do
    counter = states
    recommend_max_workers = GenServer.call(DataFlowSensors, :recommend_max_workers)
    pids_list = DynSupervisorSensors.pid_children()

    if DynSupervisorSensors.count_children()[:active] < recommend_max_workers do
      create_worker(DynSupervisorSensors, msg)
    else
      if DynSupervisorSensors.count_children()[:active] > recommend_max_workers do
        [head | _tail] = pids_list
        remove_worker(DynSupervisorSensors, head)
      end
    end

    if counter < length(pids_list) do
      counter = counter + 1
      compute_forecast(DynSupervisorSensors, pids_list, counter, msg)
      {:noreply, counter}
    else
      counter = 0
      compute_forecast(DynSupervisorSensors, pids_list, counter, msg)
      {:noreply, counter}
    end
  end

  defp compute_forecast(supevisor, pids_list, counter, msg) do
    supevisor.compune_and_send_forecast(Enum.at(pids_list, counter), msg)
  end

  defp create_worker(supevisor, msg) do
    supevisor.create_worker(msg)
  end

  defp remove_worker(supevisor, pid) do
    supevisor.remove_worker(pid)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :recv, [opts]},
      type: :worker,
      restart: :permanent
    }
  end
end
