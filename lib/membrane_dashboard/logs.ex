defmodule Membrane.Dashboard.Logs do
  @moduledoc """
  Module responsible for querying database for persisted logs.
  """

  import Membrane.Dashboard.Helpers, only: [parse_time: 1]

  alias Membrane.Dashboard.Repo

  require Logger

  @type log_t :: %{
          time: NaiveDateTime.t(),
          level: String.t(),
          component_path: String.t(),
          message: String.t()
        }

  @spec query(non_neg_integer(), non_neg_integer()) :: {:ok, [log_t()]} | :error
  def query(time_from, time_to) do
    with {:ok, %Postgrex.Result{rows: logs}} <-
           Repo.query(log_query(time_from, time_to)) do
      logs = parse_logs(logs)

      {:ok, logs}
    else
      error ->
        Logger.error(
          "Encountered error while querying database for charts data: #{inspect(error)}"
        )

        :error
    end
  end

  defp log_query(time_from, time_to) do
    """
      SELECT
      time,
      level,
      component_path,
      message
      FROM logs
      WHERE time BETWEEN '#{parse_time(time_from)}' AND '#{parse_time(time_to)}'
      ORDER BY time;
    """
  end

  defp parse_logs(logs) do
    logs
    |> Enum.map(fn [time | rest] ->
      time = NaiveDateTime.truncate(time, :millisecond)

      [:time, :level, :component_path, :message]
      |> Enum.zip([time | rest])
      |> Map.new()
    end)
  end
end
