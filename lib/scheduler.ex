defmodule Scheduler do
  @moduledoc """
  The public APIs for `Scheduler`.
  """

  alias Scheduler.Schedule
  alias Scheduler.Supervision.WorkerSupervisor
  import ShorterMaps

  def add_job(name, at_time, time_zone)
      when is_binary(name) and is_struct(at_time, Time) and is_binary(time_zone) do
    params = %{name: name, at_time: at_time, time_zone: time_zone}

    with {:ok, job} <- Schedule.create_job(params),
         {:ok, _pid} <- WorkerSupervisor.start_worker(job) do
      {:ok, "#{name} created!"}
    end
  end

  def remove_job(name) when is_binary(name) do
    with {1, nil} <- Schedule.delete_job(name),
         :ok <- WorkerSupervisor.stop_worker(%{name: name}) do
      {:ok, "#{name} has been removed from Schedule and SupervisionTree"}
    end
  end

  def update_job(name, at_time, time_zone) do
    WorkerSupervisor.stop_worker(%{name: name})
    job = Schedule.get_job(name)
    params = ~M{name, at_time, time_zone}

    with {:ok, updated_job} <- Schedule.update_job(job, params),
         {:ok, _pid} <- WorkerSupervisor.start_worker(updated_job) do
      {:ok, "#{updated_job.name} has been updated!"}
    end
  end

  def activate_job(name) do
    job = Schedule.get_job(name)

    case {job, job && job.activated} do
      {nil, _} ->
        {:error, :not_found}

      {_, true} ->
        {:info, "#{name} had already been activated!"}

      _hasnt_activated ->
        Schedule.update_job(job, %{activated: true})
        WorkerSupervisor.start_worker(job)
    end
  end

  def deactivate_job(name) do
    job = Schedule.get_job(name)

    case {job, job && job.activated} do
      {nil, _} ->
        {:error, :not_found}

      {_, false} ->
        {:info, "#{name} had already been deactivated!"}

      _activated ->
        Schedule.update_job(job, %{activated: false})
        WorkerSupervisor.stop_worker(job)
    end
  end

  ## Helper functions:

  @doc """
  This function is for functional test purpose.
  """
  def do_some_job(~M{name, at_time, time_zone}) do
    IO.puts("#{Timex.now(time_zone)}: Starting #{name} - #{at_time}")
    duration = 5000
    :timer.sleep(duration)

    File.write!("tmp/job_log.txt", "#{Timex.now(time_zone)}: DONE #{name} - #{at_time}\r\n", [
      :append
    ])

    IO.puts("#{Timex.now(time_zone)}: DONE #{name} - #{at_time}")
  end
end
