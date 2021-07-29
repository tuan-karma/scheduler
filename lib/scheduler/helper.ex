defmodule Scheduler.Helper do
  @moduledoc """
  Helper functions for scheduler app.
  Note: some functions are just fake APIs of external services.
  """

  @doc """
  This function is for functional test purpose.
  """
  def do_some_job(at_time) do
    duration = 5000

    IO.puts("#{Timex.now()}: Starting a job of #{at_time}")

    :timer.sleep(duration)
    File.write!("tmp/job_log.txt", "#{Timex.now()}: DONE job of #{at_time}\r\n", [:append])

    IO.puts("#{Timex.now()}: DONE job of #{at_time}")
  end
end
