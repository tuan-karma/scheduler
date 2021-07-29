defmodule Scheduler.Supervision.Worker do
  use GenServer, restart: :transient

  alias Scheduler.Calendar

  def start_link(%{name: name, at_time: _, time_zone: _} = params) do
    GenServer.start_link(__MODULE__, params, name: process_name(name))
  end

  @impl true
  def init(params) do
    case schedule_job(params) do
      {:noreply, _} ->
        {:ok, params}

      {:stop, _, _} ->
        :ignore
    end
  end

  @impl true
  def handle_info(:do_job, params) do
    time_zone = Map.get(params, :time_zone)

    if Calendar.business_day?(time_zone) do
      Scheduler.do_some_job(params)
    end

    schedule_job(params)
  end

  @impl true
  def terminate(reason, state) do
    IO.inspect("@terminate/2 callback")
    IO.inspect({:reason, reason})
    IO.inspect({:state, state})
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
      |> IO.inspect(label: "interval > 0")
    else
      (24 * 60 * 60 * 1000 + interval)
      |> IO.inspect(label: "interval <= 0")
    end
  end
end
