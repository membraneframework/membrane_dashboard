defmodule Membrane.DashboardWeb.Live.Components.Logs do
  @moduledoc """
  Component responsible for displaying logs.
  """

  use Membrane.DashboardWeb, :live_component

  alias Phoenix.LiveView.JS

  import Membrane.DashboardWeb.Live.Helpers, only: [info_header: 1, tooltip: 1]

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="flex flex-col m-4" phx-hook="Logs">
      <.info_header
        title="Logs"
        tooltip="Logs emitted by membrane's elements"
      />
      <%= if @logs != [] do %>
        <div class="flex flex-col bg-secondary rounded-xl h-80 w-full overflow-x-auto p-3 text-white text-sm">
          <%= for %{time: time, level: level, component_path: path, message: message} <- @logs do %>
            <div class="flex divide-solid min-w-max">
              <span class={"w-14 mr-2 #{level_style(level)}"}>[<%= String.upcase(level) %>]</span>
              <span class="w-48">[<%= time %>]</span>
              <.tooltip text={path} class="cursor-pointer -left-8">
                <span class="font-bold mr-2 text-" phx-click={JS.push("hehe", value: %{path: path})}>PATH</span>
              </.tooltip>
              <span><%= message %></span>
            </div>
          <% end %>
        </div>
      <% else %>
        <div class="rounded-xl bg-secondary p-3 description">No logs found...</div>
      <% end %>
    </div>
    """
  end

  defp level_style("warn"), do: "text-orange-400"
  defp level_style("error"), do: "text-red-700"
  defp level_style(_), do: "text-white"
end
