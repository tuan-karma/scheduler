defmodule Scheduler.Schedule do
  @moduledoc """
  The database Context. Resources: "jobs"
  """
  alias Scheduler.Repo
  alias Scheduler.Schedule.Job
  import Ecto.Query

  def list_jobs do
    Repo.all(Job)
  end

  def list_jobs(%{activated: activated?}) do
    Job
    |> where([j], j.activated == ^activated?)
    |> Repo.all()
  end

  def create_job(attrs \\ %{}) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  def get_job(name) when is_binary(name) do
    Repo.get_by(Job, name: name)
  end

  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Repo.update()
  end

  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  def delete_job(name) when is_binary(name) do
    Job
    |> where([j], j.name == ^name)
    |> Repo.delete_all()
  end
end
