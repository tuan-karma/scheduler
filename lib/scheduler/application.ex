defmodule Scheduler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Scheduler.Repo,
      {Registry, keys: :unique, name: WorkerRegistry},
      Scheduler.Supervision.WorkerSupervisor,
      Scheduler.Supervision.WorkersStarter
    ]

    opts = [strategy: :one_for_one, name: Scheduler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
