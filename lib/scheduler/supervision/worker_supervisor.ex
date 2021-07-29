defmodule Scheduler.Supervision.WorkerSupervisor do
  use DynamicSupervisor
  alias Scheduler.Supervision.Worker

  ## Public APIs
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_worker(%{activated: true} = attrs) do
    DynamicSupervisor.start_child(__MODULE__, {Worker, attrs})
  end

  def start_worker(%{activated: false}) do
    {:ok, nil}
  end

  def stop_worker(%{name: name}) when is_binary(name) do
    case Registry.lookup(WorkerRegistry, name) do
      [{pid, _}] ->
        {:ok, GenServer.stop(pid)}

      [] ->
        {:ok, nil}
    end
  end

  ## Callbacks
  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
