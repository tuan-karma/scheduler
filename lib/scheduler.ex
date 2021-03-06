defmodule Scheduler do
  @moduledoc """
  The public APIs for `Scheduler`.
  """

  alias Scheduler.Schedule
  alias Scheduler.Supervision.WorkerSupervisor
  import ShorterMaps

  @doc """
  Add a job to database and start a worker in supervision tree to do that job at the time.

  ## Examples

      iex> Scheduler.add_job(%{name: "job1", at_time: ~T[11:25:32], time_zone: "Asia/Ho_Chi_Minh"})
      {:ok, "Job created"}

  """
  def add_job(%{name: _, at_time: _, time_zone: _} = params) do
    with {:ok, job} <- Schedule.create_job(params),
         {:ok, _pid} <- WorkerSupervisor.start_worker(job) do
      {:ok, "Job created"}
    end
  end

  def remove_job(%{name: name}) do
    with {1, nil} <- Schedule.delete_job(name),
         {:ok, _} <- WorkerSupervisor.stop_worker(%{name: name}) do
      {:ok, "Job removed"}
    end
  end

  def update_job(%{name: name, at_time: _, time_zone: _} = params) do
    WorkerSupervisor.stop_worker(%{name: name})

    with {:ok, updated_job} <- Schedule.update_job_by_name(name, params),
         {:ok, _pid} <- WorkerSupervisor.start_worker(updated_job) do
      {:ok, "Job updated"}
    end
  end

  def activate_job(%{name: name}) do
    with {:ok, updated_job} <- Schedule.update_job_by_name(name, %{activated: true}),
         {:ok, _pid} <- WorkerSupervisor.start_worker(updated_job) do
      {:ok, "Job activated"}
    end
  end

  def deactivate_job(%{name: name}) do
    with {:ok, updated_job} <- Schedule.update_job_by_name(name, %{activated: false}),
         {:ok, _} <- WorkerSupervisor.stop_worker(updated_job) do
      {:ok, "Job deactivated"}
    end
  end

  @doc """
  This is a API function to dispatch job needed to do based on params (aka. name of the job).
  A call to external service can be done from this function.
  """
  def do_the_job(params) do
    do_some_job(params)
  end

  ## Helper functions:

  ## The following function is for functional test purpose.
  defp do_some_job(~M{name, at_time, time_zone}) do
    IO.puts("#{Timex.now(time_zone)}: Starting #{name} - #{at_time}")
    duration = 15000
    :timer.sleep(duration)

    File.write!("tmp/job_log.txt", "#{Timex.now(time_zone)}: DONE #{name} - #{at_time}\r\n", [
      :append
    ])

    IO.puts("#{Timex.now(time_zone)}: DONE #{name} - #{at_time}")
  end
end
