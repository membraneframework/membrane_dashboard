defmodule Membrane.DashboardWeb.DashboardLive do
  @moduledoc """
  Live view controller for Membrane's dashboard.
  """
  use Membrane.DashboardWeb, :live_view

  import Membrane.DashboardWeb.Live.Helpers

  alias Membrane.Dashboard.{DataManager, Helpers}
  alias Membrane.DashboardWeb.Router.Helpers, as: Routes

  require Logger

  @metrics_with_descriptions %{
    "caps" => "total number of distinct caps received",
    "event" => "total number of received events",
    "store" => "current size of InputBuffer during store operation",
    "take_and_demand" => "current size of InputBuffer during take_and_demand operation",
    "buffer" => "number of processed buffers per second",
    "bitrate" => "number of bits processed per second",
    "queue_len" => "number of pending messages in message queue"
  }

  @initial_time_offset 60
  @initial_accuracy 100

  @update_time 5

  # initially:
  # - time range is the last `@initial_time_offset` seconds
  # - live update is enabled - now updates `@update_time` seconds after last sending data to uPlot
  # - charts are created based on current metrics in database
  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        # data query params
        time_from: now(-@initial_time_offset),
        time_to: now(),
        accuracy: @initial_accuracy,
        update_range: @initial_time_offset,

        # cached query data
        logs: [],
        available_metrics: @metrics_with_descriptions,
        metrics: [],
        data_manager: nil,

        # real-time update timer
        update_ref: nil,
        update: false,

        # UI related
        #
        active_path: [],
        data_loading: false,
        top_level_combos: nil,
        alive_pipelines: []
      )

    {:ok, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    case socket.assigns.data_manager do
      nil ->
        :ok

      {_ref, pid} ->
        GenServer.stop(pid)
    end
  end

  # updates charts and reloads dagree when live update is enabled
  @impl true
  def handle_params(%{"mode" => "update", "from" => from, "to" => to}, _session, socket) do
    # if we are in update mode and there is no data then just push patch that will do the full query
    with {_ref, data_manager} <- socket.assigns.data_manager,
         true <- DataManager.loaded?(data_manager) do
      socket
      |> push_patch_with_params(%{from: from, to: to})
      |> noreply()
    else
      _unmatched ->
        with true <- connected?(socket),
             {from, to} <- extract_time_range(%{"from" => from, "to" => to}, socket) do
          socket
          # check if this is correct
          |> schedule_query(from, to, mode: :update)
          |> noreply()
        else
          _unmatched ->
            socket
            |> plan_update()
            |> noreply()
        end
    end
  end

  # reloads full charts and dagre after pressing any button or reloading page
  def handle_params(params, _session, socket) do
    with true <- connected?(socket),
         {from, to} <- extract_time_range(params, socket),
         accuracy <- extract_accuracy(params, socket),
         update <- extract_update_status(params, socket),
         update_range <- extract_update_time_range(params, socket) do
      socket
      |> schedule_query(from, to,
        mode: if(socket.assigns.update and update, do: :update, else: :full),
        accuracy: accuracy
      )
      |> assign(
        accuracy: accuracy,
        update: update,
        update_range: update_range
      )
      |> noreply()
    else
      error ->
        Logger.error("Encountered invalid arguments when handling params: #{inspect(error)}")

        noreply(socket)
    end
  end

  ##################
  ### DATA QUERY ###
  ##################

  @impl true
  def handle_info({:data_query, :query_start}, socket) do
    socket
    |> assign(data_loading: true)
    |> noreply()
  end

  def handle_info({:data_query, :query_end, {time_from, time_to}}, socket) do
    socket
    |> assign(data_loading: false, time_from: time_from, time_to: time_to)
    |> plan_update()
    |> noreply()
  end

  def handle_info({:data_query, :charts, {mode, metric, chart}}, socket)
      when mode in [:full, :update] do
    socket
    |> push_event("charts:#{mode}", %{metric: metric, data: chart})
    |> noreply()
  end

  def handle_info({:data_query, :dagre, data}, socket) do
    socket
    |> push_event("dagre:data", %{data: data})
    |> noreply()
  end

  def handle_info({:data_query, :alive_pipelines, alive_pipelines}, socket) do
    socket
    |> assign(alive_pipelines: alive_pipelines)
    |> noreply()
  end

  def handle_info({:data_query, :logs, logs}, socket) do
    socket
    |> assign(logs: logs)
    |> noreply()
  end

  #######################
  ### ELEMENTS SELECT ###
  #######################

  def handle_info({:elements_select, :reset}, socket) do
    socket
    |> assign(active_path: [])
    |> push_charts_search_prefix()
    |> noreply()
  end

  def handle_info({:elements_select, :apply_filter}, socket) do
    socket
    |> push_charts_search_prefix()
    |> noreply()
  end

  #########################
  ### PIPELINES MARKING ###
  #########################

  def handle_info({:alive_pipelines, {:mark_dead, pipeline}}, socket) do
    case Membrane.Dashboard.PipelineMarking.mark_dead(pipeline) do
      {inserted, nil} when inserted > 0 ->
        alive_pipelines = socket.assigns.alive_pipelines |> Enum.reject(&(&1 == pipeline))

        assign(socket, alive_pipelines: alive_pipelines)

      _other ->
        Logger.error("Tried to mark '#{pipeline}' as dead while not being alive...")
        socket
    end
    |> noreply()
  end

  ######################
  ### METRICS SELECT ###
  ######################

  def handle_info({:metrics_select, {type, metric}}, socket) do
    socket =
      case type do
        :add ->
          update(socket, :metrics, fn metrics -> metrics ++ [metric] end)

        :remove ->
          update(socket, :metrics, fn metrics -> Enum.reject(metrics, &(&1 == metric)) end)
      end

    socket
    |> push_event("charts:metrics:selected", %{metrics: socket.assigns.metrics})
    |> noreply()
  end

  ######################
  ### OTHER MESSAGES ###
  ######################

  def handle_info(
        {:DOWN, ref, :process, pid, _reason},
        %{assigns: %{data_manager: {ref, pid}}} = socket
      ) do
    Logger.error("Data manager is down, restarting...")

    {:ok, data_manager} = DataManager.start()
    ref = Process.monitor(data_manager)

    socket
    |> assign(data_manager: {ref, data_manager}, data_loading: false)
    |> put_flash(:error, "Extracting data has failed...")
    |> noreply()
  end

  # this message is the last message sent from query task
  def handle_info({:update_query_time, time_from, time_to}, socket) do
    socket
    |> assign(time_from: time_from, time_to: time_to)
    |> case do
      # if the timer had not been set then do nothing
      %{assigns: %{update_ref: nil}} = socket ->
        socket

      socket ->
        plan_update(socket)
    end
    |> noreply()
  end

  def handle_info({:set_data_loading, loading}, socket) do
    socket
    |> assign(data_loading: loading)
    |> noreply()
  end

  def handle_info(:update, socket) do
    socket
    |> push_patch_with_params(%{
      mode: :update,
      from: now(-socket.assigns.update_range),
      to: now()
    })
    |> noreply()
  end

  #############################
  ### DAGRE FRONTEND EVENTS ###
  #############################

  def handle_event("dagre:top-level-combos", combos, socket),
    do: socket |> assign(top_level_combos: combos) |> noreply()

  def handle_event("dagre:focus:path", %{"path" => path}, socket) do
    socket = assign(socket, active_path: path)

    handle_info({:elements_select, :apply_filter}, socket)
  end

  def handle_event("dagre:focus:combo:" <> combo_id, _value, socket) do
    socket
    |> push_event("dagre:focus:combo", %{id: combo_id})
    |> noreply()
  end

  #################################
  ### SEARCH FRONTEND EVENTS ###
  #################################

  @impl true
  def handle_event("search:refresh", %{"timeFrom" => time_from, "timeTo" => time_to}, socket) do
    case parse_time_range(time_from, time_to) do
      {:ok, {from, to}} ->
        socket
        |> assign(:active_path, [])
        |> push_patch_with_params(%{from: from, to: to, update: false})
        |> cancel_update()

      {:error, reason} ->
        put_flash(socket, :error, reason)
    end
    |> noreply()
  end

  def handle_event("search:last-x-min", %{"value" => minutes}, socket) do
    case Integer.parse(minutes) do
      {minutes_as_int, _rem} ->
        socket
        |> assign(:active_path, [])
        |> push_patch_with_params(%{
          from: now(-60 * minutes_as_int),
          to: now(),
          update_range: 60 * minutes_as_int
        })

      :error ->
        put_flash(socket, :error, ~s(Invalid format of "Last x minutes"))
    end
    |> noreply()
  end

  def handle_event("search:toggle-update-mode", _value, socket) do
    was_update = socket.assigns.update

    socket
    |> assign(update: !socket.assigns.update)
    |> then(if was_update, do: &cancel_update/1, else: &plan_update/1)
    |> noreply()
  end

  def handle_event("search:apply-accuracy", %{"accuracy" => accuracy}, socket) do
    {accuracy, ""} = Integer.parse(accuracy)

    socket
    |> push_patch_with_params(%{
      accuracy: accuracy,
      from: socket.assigns.time_from,
      to: socket.assigns.time_to
    })
    |> noreply()
  end

  def handle_event("search:" <> event, _params, socket) when event in ["go-next", "go-prev"] do
    interval =
      case event do
        "go-next" -> socket.assigns.update_range * 1_000
        "go-prev" -> -socket.assigns.update_range * 1_000
      end

    socket
    |> push_patch_with_params(%{
      from: socket.assigns.time_from + interval,
      to: socket.assigns.time_to + interval
    })
    |> noreply()
  end

  defp push_charts_search_prefix(socket) do
    series_prefix = Enum.join(socket.assigns.active_path, "/")

    push_event(socket, "charts:filter", %{seriesPrefix: series_prefix})
  end

  @doc """
  Changes UNIX time to ISO 8601 format.
  """
  @spec format_time(non_neg_integer()) :: String.t()
  def format_time(time) do
    time
    |> Helpers.add_to_beginning_of_time()
    |> DateTime.to_iso8601()
  end

  # returns current UNIX time with optional offset
  defp now(offset \\ 0, time_unit \\ :second) do
    DateTime.utc_now()
    |> DateTime.add(offset, time_unit)
    |> DateTime.to_unix(:millisecond)
  end

  defp start_data_manager(socket) when is_nil(socket.assigns.data_manager) do
    {:ok, data_manager} = DataManager.start()
    ref = Process.monitor(data_manager)

    assign(socket, data_manager: {ref, data_manager})
  end

  defp start_data_manager(socket), do: socket

  defp schedule_query(socket, time_from, time_to, options) do
    socket = start_data_manager(socket)
    metrics = socket.assigns.metrics
    accuracy = socket.assigns.accuracy

    {_ref, manager} = socket.assigns.data_manager

    options =
      Keyword.merge(options,
        time_from: time_from,
        time_to: time_to,
        metrics: metrics,
        accuracy: accuracy
      )

    DataManager.query(manager, options)

    socket
  end

  # next update will be in `@update_time` seconds
  defp plan_update(socket) when socket.assigns.update do
    unless is_nil(socket.assigns.update_ref) do
      Process.cancel_timer(socket.assigns.update_ref)
    end

    ref = Process.send_after(self(), :update, @update_time * 1000)
    assign(socket, update_ref: ref)
  end

  defp plan_update(socket), do: socket

  defp cancel_update(socket) do
    unless is_nil(socket.assigns.update_ref) do
      Process.cancel_timer(socket.assigns.update_ref)
    end

    assign(socket, update_ref: nil)
  end

  # returns pair of UNIX time values made from strings in params or extracted from assigns in socket
  defp extract_time_range(%{"from" => from, "to" => to}, _socket),
    do: {String.to_integer(from), String.to_integer(to)}

  defp extract_time_range(_params, socket),
    do: {socket.assigns.time_from, socket.assigns.time_to}

  # returns accuracy extracted from strings in params or from assigns in socket
  defp extract_accuracy(%{"accuracy" => accuracy}, _socket),
    do: String.to_integer(accuracy)

  defp extract_accuracy(_params, socket),
    do: socket.assigns.accuracy

  # returns information whether the charts should be updated in real time
  defp extract_update_status(%{"update" => update}, _socket) do
    update == "true"
  end

  defp extract_update_status(_params, socket),
    do: socket.assigns.update_ref != nil

  # returns number of seconds in charts' time range; important for live update
  defp extract_update_time_range(%{"update_range" => update_range}, _socket),
    do: String.to_integer(update_range)

  defp extract_update_time_range(_params, socket),
    do: socket.assigns.update_range

  # returns pair of UNIX time values from DateTime in ISO 8601 format
  defp parse_time_range(from, to) do
    with [{:ok, from, _from_offset}, {:ok, to, _to_offset}] <-
           [from, to] |> Enum.map(&DateTime.from_iso8601/1),
         [unix_from, unix_to] <- [from, to] |> Enum.map(&DateTime.to_unix(&1, :millisecond)) do
      if unix_to > unix_from do
        {:ok, {unix_from, unix_to}}
      else
        {:error, "\"from\" should be before \"to\""}
      end
    else
      _invalid_format -> {:error, "Invalid time range format"}
    end
  end

  # executes push_patch/2 function with given `params` to invoke handle_params/3
  defp push_patch_with_params(socket, params),
    do: push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))

  defp noreply(socket) do
    {:noreply, socket}
  end
end
