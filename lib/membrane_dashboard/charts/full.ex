defmodule Membrane.Dashboard.Charts.Full do
  @moduledoc """
  Module responsible for preparing data for uPlot charts when they are being entirely reloaded.

  Every chart visualizes sizes of buffers found when processing one particular method in pipelines. Chart data returned 
  by query is a list of maps (one for every chart) which consist of:
  - series - list of maps with labels. Used as legend in uPlot;
  - data - list of lists. Represents points on the chart. First list contains timestamps in UNIX time (x axis ticks).
    Every next list have information about one pipeline path. Such list have max buffer size for every timestamp from
    first list.
  """

  import Membrane.Dashboard.Charts.Helpers

  alias Membrane.Dashboard.Repo

  @type chart_data_t :: %{
          series: [%{label: String.t()}],
          data: [[integer()]]
        }

  @doc """
  Queries database to get data appropriate for uPlot. Returns data for all given methods, time interval
  between `time_from` and `time_to` and given `accuracy`.
  """
  @spec query([String.t()], non_neg_integer(), non_neg_integer(), non_neg_integer()) ::
          {:ok, [chart_data_t()], [String.t()]}
  def query(methods, time_from, time_to, accuracy) do
    {charts_data, paths} =
      methods
      |> Enum.map(&one_chart_query(&1, time_from, time_to, accuracy))
      |> Enum.unzip()

    {:ok, charts_data, paths}
  end

  # returns data for one method for the given time interval and `accuracy` (all in milliseconds)
  defp one_chart_query(method, time_from, time_to, accuracy) do
    with {:ok, %Postgrex.Result{rows: rows}} <-
           create_sql_query(accuracy, time_from, time_to, method) |> Repo.query() do
      interval = create_interval(time_from, time_to, accuracy)
      data_by_paths = to_series(rows, interval)

      chart_data = %{
        series: extract_opt_series(data_by_paths),
        data: extract_data(interval, data_by_paths)
      }

      {chart_data, extract_paths(data_by_paths)}
    else
      _ -> {%{series: [], data: [[]]}, []}
    end
  end

  # returns list of paths (they are in the same order as in the series that will be sent to uPlot)
  defp extract_paths(data_by_paths) do
    data_by_paths
    |> Enum.map(fn {path, _data} -> path end)
  end

  # returns list of maps serializable to Series objects in uPlot
  # that list will be used to create legend for uPlot
  # example list: [%{label: "time"}, %{label: "pipeline@<0.584.0>/:realtimer_video/:input:"}, %{label: "pipeline@..."}]
  defp extract_opt_series(data_by_paths) do
    series =
      data_by_paths
      |> Enum.map(fn {path, _data} -> %{label: path} end)

    [%{label: "time"} | series]
  end

  # returns data for uPlot in format: [x axis labels, series 1, series 2, ...]
  defp extract_data(interval, data_by_paths) do
    data =
      data_by_paths
      |> Enum.map(fn {_path, data} -> data end)

    [interval | data]
  end
end