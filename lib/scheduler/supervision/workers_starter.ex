defmodule Scheduler.Supervision.WorkersStarter do
  @moduledoc """
  Start all "jobs" stored in database at_and_only_at the application starting-up/restart.
  """
  use GenServer, restart: :temporary
  alias Scheduler.Schedule
  alias Scheduler.Supervision.WorkerSupervisor

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(state) do
    start_jobs_in_Schedule()
    {:ok, state}
  end

  defp start_jobs_in_Schedule() do
    Schedule.list_jobs(%{activated: true})
    |> Enum.map(fn job ->
      WorkerSupervisor.start_worker(job)
    end)
  end
end
