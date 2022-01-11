defmodule Membrane.Dashboard.Helpers do
  @moduledoc false

  @beginning_of_time ~U[1970-01-01 00:00:00.000Z]

  @doc """
  Receives UNIX time in milliseconds add returns DateTime (appropriate format for SQL queries).
  """
  @spec parse_time(non_neg_integer() | NaiveDateTime.t() | DateTime.t()) :: DateTime.t()
  def parse_time(time) when is_number(time),
    do: Membrane.Dashboard.Helpers.add_to_beginning_of_time(time)

  def parse_time(%module{} = time) when module in [NaiveDateTime, DateTime] do
    time
  end

  @doc """
  Adds given time * unit to beginning of UNIX time.
  """
  @spec add_to_beginning_of_time(non_neg_integer(), System.time_unit()) :: DateTime.t()
  def add_to_beginning_of_time(time, unit \\ :millisecond),
    do: @beginning_of_time |> DateTime.add(time, unit)
end
