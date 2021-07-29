defmodule Scheduler.Schedule.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field(:name, :string)
    field(:interval, :integer)
    field(:at_time, :time)
    field(:time_zone, :string)
    field(:activated, :boolean, default: true)
  end

  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:name, :interval, :at_time, :time_zone, :activated])
    |> validate_required([:name, :at_time, :time_zone])
    |> unique_constraint(:name)
  end
end
