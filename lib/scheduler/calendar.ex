defmodule Scheduler.Calendar do
  @moduledoc """
  Calendar context
  """

  @doc """
  Check business day based on time zone and a calendar stored in DB which can be update by user for each country/land.

  Example

    iex> business_day?("Asia/Ho_Chi_Minh")
    true

  Now this function just return true for week day (Monday to Friday). In production you should implement a calendar database.
  """
  def business_day?(time_zone) when is_binary(time_zone) do
    datetime = Timex.now(time_zone)
    Timex.weekday(datetime) < 6
  end
end
