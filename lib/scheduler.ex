defmodule Scheduler do
  @moduledoc """
  The public APIs for `Scheduler`.
  """

  alias Scheduler.Schedule
  alias Scheduler.Supervision.WorkerSupervisor
  import ShorterMaps

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

  ## Helper functions:

  @doc """
  This function is for functional test purpose.
  """
  def do_some_job(~M{name, at_time, time_zone}) do
    IO.puts("#{Timex.now(time_zone)}: Starting #{name} - #{at_time}")
    duration = 15000
    :timer.sleep(duration)

    File.write!("tmp/job_log.txt", "#{Timex.now(time_zone)}: DONE #{name} - #{at_time}\r\n", [
      :append
    ])

    IO.puts("#{Timex.now(time_zone)}: DONE #{name} - #{at_time}")
  end
end
