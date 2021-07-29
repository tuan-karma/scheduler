defmodule Scheduler.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :name, :string, null: false
      add :interval, :integer
      add :at_time, :time
      add :time_zone, :string
      add :activated, :boolean
    end

    create unique_index(:jobs, [:name])
  end
end
