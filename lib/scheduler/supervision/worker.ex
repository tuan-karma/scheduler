defmodule Scheduler.Supervision.Worker do
  use GenServer, restart: :transient

  alias Scheduler.Calendar

  def start_link(%{name: name, at_time: _, time_zone: _} = params) do
    GenServer.start_link(__MODULE__, params, name: process_name(name))
  end

  @impl true
  def init(params) do
    schedule_job(params)
    {:ok, params}
  end

  @impl true
  def handle_info(:do_job, params) do
    time_zone = Map.get(params, :time_zone)

    if Calendar.business_day?(time_zone) do
      Scheduler.do_the_job(params)
    end

    schedule_job(params)
  end

  defp process_name(name) when is_binary(name) do
    {:via, Registry, {WorkerRegistry, name}}
  end

  defp schedule_job(params) do
    interval = interval_from_now(params)
    Process.send_after(self(), :do_job, interval)
    {:noreply, params}
  end

  defp interval_from_now(%{at_time: at_time, time_zone: time_zone}) do
    now_time = Timex.now(time_zone) |> DateTime.to_time()
    interval = Timex.diff(at_time, now_time, :milliseconds)

    if interval > 0 do
      interval
    else
      # next day:
      24 * 60 * 60 * 1000 + interval
    end
  end
end
