defmodule Membrane.DashboardWeb.Live.Helpers do
  @moduledoc """
  Modules consisting different svg icons.
  """

  use Phoenix.Component

  @spec search_icon(map) :: Phoenix.LiveView.Rendered.t()
  def search_icon(assigns) do
    assigns = assign_class(assigns)

    ~H"""
      <svg class={"default-icon #{@class}"} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <path fill="currentColor" d="M16.32 14.9l5.39 5.4a1 1 0 0 1-1.42 1.4l-5.38-5.38a8 8 0 1 1 1.41-1.41zM10 16a6 6 0 1 0 0-12 6 6 0 0 0 0 12z" />
      </svg>
    """
  end

  @spec circular_progress_icon(map) :: Phoenix.LiveView.Rendered.t()
  def circular_progress_icon(assigns) do
    assigns = assign_class(assigns)

    ~H"""
      <svg class={"animate-spin default-icon #{@class}"} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
      </svg>
    """
  end

  @spec clock_icon(map) :: Phoenix.LiveView.Rendered.t()
  def clock_icon(assigns) do
    assigns = assign_class(assigns)

    ~H"""
      <svg class={"default-icon #{@class}"} claxmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path fill="currentColor" d="M 12 2 C 6.4889971 2 2 6.4889971 2 12 C 2 17.511003 6.4889971 22 12 22 C 17.511003 22 22 17.511003 22 12 C 22 6.4889971 17.511003 2 12 2 z M 12 4 C 16.430123 4 20 7.5698774 20 12 C 20 16.430123 16.430123 20 12 20 C 7.5698774 20 4 16.430123 4 12 C 4 7.5698774 7.5698774 4 12 4 z M 11 6 L 11 12.414062 L 15.292969 16.707031 L 16.707031 15.292969 L 13 11.585938 L 13 6 L 11 6 z"></path>
      </svg>
    """
  end

  @spec image_icon(map) :: Phoenix.LiveView.Rendered.t()
  def image_icon(assigns) do
    assigns = assign_class(assigns)

    ~H"""
    <svg class={"default-icon #{@class}"} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
      <path stroke="none" fill="currentColor" d="M4.828 21l-.02.02-.021-.02H2.992A.993.993 0 0 1 2 20.007V3.993A1 1 0 0 1 2.992 3h18.016c.548 0 .992.445.992.993v16.014a1 1 0 0 1-.992.993H4.828zM20 15V5H4v14L14 9l6 6zm0 2.828l-6-6L6.828 19H20v-1.172zM8 11a2 2 0 1 1 0-4 2 2 0 0 1 0 4z"/>
    </svg>
    """
  end

  @spec layout_icon(map) :: Phoenix.LiveView.Rendered.t()
  def layout_icon(assigns) do
    assigns = assign_class(assigns)

    ~H"""
      <svg class={"default-icon #{@class}"} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
        <path stroke="none" fill="currentColor" d="M5 8h14V5H5v3zm9 11v-9H5v9h9zm2 0h3v-9h-3v9zM4 3h16a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1z"/>
      </svg>
    """
  end

  @spec fullscreen_exit_icon(map) :: Phoenix.LiveView.Rendered.t()
  def fullscreen_exit_icon(assigns) do
    assigns = assign_class(assigns)

    ~H"""
    <svg class={"default-icon #{@class}"} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
      <path stroke="none" fill="currentColor" d="M18 7h4v2h-6V3h2v4zM8 9H2V7h4V3h2v6zm10 8v4h-2v-6h6v2h-4zM8 15v6H6v-4H2v-2h6z"/>
    </svg>
    """
  end

  @spec focus_icon(map) :: Phoenix.LiveView.Rendered.t()
  def focus_icon(assigns) do
    assigns = assign_class(assigns)

    ~H"""
    <svg class={"default-icon #{@class}"} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
      <path stroke="none" fill="currentColor" d="M13 1l.001 3.062A8.004 8.004 0 0 1 19.938 11H23v2l-3.062.001a8.004 8.004 0 0 1-6.937 6.937L13 23h-2v-3.062a8.004 8.004 0 0 1-6.938-6.937L1 13v-2h3.062A8.004 8.004 0 0 1 11 4.062V1h2zm-1 5a6 6 0 1 0 0 12 6 6 0 0 0 0-12zm0 4a2 2 0 1 1 0 4 2 2 0 0 1 0-4z"/>
    </svg>
    """
  end

  @spec ruler_icon(map) :: Phoenix.LiveView.Rendered.t()
  def ruler_icon(assigns) do
    assigns = assign_class(assigns)

    ~H"""
      <svg class={"default-icon #{@class}"} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
        <path stroke="none" fill="currentColor" d="M6.343 14.621L3.515 17.45l3.535 3.535L20.485 7.55 16.95 4.015l-2.122 2.121 1.415 1.414-1.415 1.414-1.414-1.414-2.121 2.122 2.121 2.12L12 13.208l-2.121-2.121-2.122 2.121 1.415 1.414-1.415 1.415-1.414-1.415zM17.657 1.893l4.95 4.95a1 1 0 0 1 0 1.414l-14.85 14.85a1 1 0 0 1-1.414 0l-4.95-4.95a1 1 0 0 1 0-1.414l14.85-14.85a1 1 0 0 1 1.414 0z"/>
      </svg>
    """
  end

  @spec arrow_down_icon(map) :: Phoenix.LiveView.Rendered.t()
  def arrow_down_icon(assigns) do
    assigns = assign_class(assigns)

    ~H"""
    <svg class={"default-icon #{@class}"} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
      <path stroke="none" fill="currentColor" d="M13 16.172l5.364-5.364 1.414 1.414L12 20l-7.778-7.778 1.414-1.414L11 16.172V4h2v12.172z"/>
    </svg>
    """
  end

  @spec phoenix_icon(map) :: Phoenix.LiveView.Rendered.t()
  def phoenix_icon(assigns) do
    assigns = assign_class(assigns)

    ~H"""
    <svg class={@class} aria-hidden="true" focusable="false" data-prefix="fab" data-icon="phoenix-framework" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 512">
      <path fill="currentColor" d="M212.9 344.3c3.8-.1 22.8-1.4 25.6-2.2-2.4-2.6-43.6-1-68-49.6-4.3-8.6-7.5-17.6-6.4-27.6 2.9-25.5 32.9-30 52-18.5 36 21.6 63.3 91.3 113.7 97.5 37 4.5 84.6-17 108.2-45.4-.6-.1-.8-.2-1-.1-.4 .1-.8 .2-1.1 .3-33.3 12.1-94.3 9.7-134.7-14.8-37.6-22.8-53.1-58.7-51.8-74.6 1.8-21.3 22.9-23.2 35.9-19.6 14.4 3.9 24.4 17.6 38.9 27.4 15.6 10.4 32.9 13.7 51.3 10.3 14.9-2.7 34.4-12.3 36.5-14.5-1.1-.1-1.8-.1-2.5-.2-6.2-.6-12.4-.8-18.5-1.7C279.8 194.5 262.1 47.4 138.5 37.9 94.2 34.5 39.1 46 2.2 72.9c-.8 .6-1.5 1.2-2.2 1.8 .1 .2 .1 .3 .2 .5 .8 0 1.6-.1 2.4-.2 6.3-1 12.5-.8 18.7 .3 23.8 4.3 47.7 23.1 55.9 76.5 5.3 34.3-.7 50.8 8 86.1 19 77.1 91 107.6 127.7 106.4zM75.3 64.9c-.9-1-.9-1.2-1.3-2 12.1-2.6 24.2-4.1 36.6-4.8-1.1 14.7-22.2 21.3-35.3 6.8zm196.9 350.5c-42.8 1.2-92-26.7-123.5-61.4-4.6-5-16.8-20.2-18.6-23.4l.4-.4c6.6 4.1 25.7 18.6 54.8 27 24.2 7 48.1 6.3 71.6-3.3 22.7-9.3 41-.5 43.1 2.9-18.5 3.8-20.1 4.4-24 7.9-5.1 4.4-4.6 11.7 7 17.2 26.2 12.4 63-2.8 97.2 25.4 2.4 2 8.1 7.8 10.1 10.7-.1 .2-.3 .3-.4 .5-4.8-1.5-16.4-7.5-40.2-9.3-24.7-2-46.3 5.3-77.5 6.2zm174.8-252c16.4-5.2 41.3-13.4 66.5-3.3 16.1 6.5 26.2 18.7 32.1 34.6 3.5 9.4 5.1 19.7 5.1 28.7-.2 0-.4 0-.6 .1-.2-.4-.4-.9-.5-1.3-5-22-29.9-43.8-67.6-29.9-50.2 18.6-130.4 9.7-176.9-48-.7-.9-2.4-1.7-1.3-3.2 .1-.2 2.1 .6 3 1.3 18.1 13.4 38.3 21.9 60.3 26.2 30.5 6.1 54.6 2.9 79.9-5.2zm102.7 117.5c-32.4 .2-33.8 50.1-103.6 64.4-18.2 3.7-38.7 4.6-44.9 4.2v-.4c2.8-1.5 14.7-2.6 29.7-16.6 7.9-7.3 15.3-15.1 22.8-22.9 19.5-20.2 41.4-42.2 81.9-39 23.1 1.8 29.3 8.2 36.1 12.7 .3 .2 .4 .5 .7 .9-.5 0-.7 .1-.9 0-7-2.7-14.3-3.3-21.8-3.3zm-12.3-24.1c-.1 .2-.1 .4-.2 .6-28.9-4.4-48-7.9-68.5 4-17 9.9-31.4 20.5-62 24.4-27.1 3.4-45.1 2.4-66.1-8-.3-.2-.6-.4-1-.6 0-.2 .1-.3 .1-.5 24.9 3.8 36.4 5.1 55.5-5.8 22.3-12.9 40.1-26.6 71.3-31 29.6-4.1 51.3 2.5 70.9 16.9zM268.6 97.3c-.6-.6-1.1-1.2-2.1-2.3 7.6 0 29.7-1.2 53.4 8.4 19.7 8 32.2 21 50.2 32.9 11.1 7.3 23.4 9.3 36.4 8.1 4.3-.4 8.5-1.2 12.8-1.7 .4-.1 .9 0 1.5 .3-.6 .4-1.2 .9-1.8 1.2-8.1 4-16.7 6.3-25.6 7.1-26.1 2.6-50.3-3.7-73.4-15.4-19.3-9.9-36.4-22.9-51.4-38.6zM640 335.7c-3.5 3.1-22.7 11.6-42.7 5.3-12.3-3.9-19.5-14.9-31.6-24.1-10-7.6-20.9-7.9-28.1-8.4 .6-.8 .9-1.2 1.2-1.4 14.8-9.2 30.5-12.2 47.3-6.5 12.5 4.2 19.2 13.5 30.4 24.2 10.8 10.4 21 9.9 23.1 10.5 .1-.1 .2 0 .4 .4zm-212.5 137c2.2 1.2 1.6 1.5 1.5 2-18.5-1.4-33.9-7.6-46.8-22.2-21.8-24.7-41.7-27.9-48.6-29.7 .5-.2 .8-.4 1.1-.4 13.1 .1 26.1 .7 38.9 3.9 25.3 6.4 35 25.4 41.6 35.3 3.2 4.8 7.3 8.3 12.3 11.1z">
      </path>
    </svg>
    """
  end

  @spec small_arrow_up_icon(map()) :: Phoenix.LiveView.Rendered.t()
  def small_arrow_up_icon(assigns) do
    assigns = assign_class(assigns)

    ~H"""
    <svg class={@class} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
      <path stroke="none" fill="currentColor" d="M12 10.828l-4.95 4.95-1.414-1.414L12 8l6.364 6.364-1.414 1.414z"/>
    </svg>
    """
  end

  @spec info_icon(map()) :: Phoenix.LiveView.Rendered.t()
  def info_icon(assigns) do
    assigns = assign_class(assigns)

    ~H"""
    <svg class={"default-icon #{@class}"} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
      <path stroke="none" fill="currentColor" d="M12 22C6.477 22 2 17.523 2 12S6.477 2 12 2s10 4.477 10 10-4.477 10-10 10zm0-2a8 8 0 1 0 0-16 8 8 0 0 0 0 16zM11 7h2v2h-2V7zm0 4h2v6h-2v-6z"/>
    </svg>
    """
  end

  @spec opentelemetry_icon(map()) :: Phoenix.LiveView.Rendered.t()
  def opentelemetry_icon(assigns) do
    assigns = assign_class(assigns)

    ~H"""
    <svg class={@class} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="-12.70 -12.70 1024.40 1024.40">
      <style> {enable-background:new 0 0 1000 1000}</style>
      <path fill="#f5a800" d="M528.7 545.9c-42 42-42 110.1 0 152.1s110.1 42 152.1 0 42-110.1 0-152.1-110.1-42-152.1 0zm113.7 113.8c-20.8 20.8-54.5 20.8-75.3 0-20.8-20.8-20.8-54.5 0-75.3 20.8-20.8 54.5-20.8 75.3 0 20.8 20.7 20.8 54.5 0 75.3zm36.6-643l-65.9 65.9c-12.9 12.9-12.9 34.1 0 47l257.3 257.3c12.9 12.9 34.1 12.9 47 0l65.9-65.9c12.9-12.9 12.9-34.1 0-47L725.9 16.7c-12.9-12.9-34-12.9-46.9 0zM217.3 858.8c11.7-11.7 11.7-30.8 0-42.5l-33.5-33.5c-11.7-11.7-30.8-11.7-42.5 0L72.1 852l-.1.1-19-19c-10.5-10.5-27.6-10.5-38 0-10.5 10.5-10.5 27.6 0 38l114 114c10.5 10.5 27.6 10.5 38 0s10.5-27.6 0-38l-19-19 .1-.1 69.2-69.2z"/>
      <path fill="#425cc7" d="M565.9 205.9L419.5 352.3c-13 13-13 34.4 0 47.4l90.4 90.4c63.9-46 153.5-40.3 211 17.2l73.2-73.2c13-13 13-34.4 0-47.4L613.3 205.9c-13-13.1-34.4-13.1-47.4 0zm-94 322.3l-53.4-53.4c-12.5-12.5-33-12.5-45.5 0L184.7 663.2c-12.5 12.5-12.5 33 0 45.5l106.7 106.7c12.5 12.5 33 12.5 45.5 0L458 694.1c-25.6-52.9-21-116.8 13.9-165.9z"/>
    </svg>
    """
  end

  @spec tooltip(map()) :: Phoenix.LiveView.Rendered.t()
  def tooltip(assigns) do
    assigns = assign_class(assigns)

    min_width = Map.get(assigns, :min_width, "min-w-max")

    ~H"""
    <div data-type="tooltip" class="group relative">
      <%= render_slot(@inner_block) %>
      <span class={"#{@class} transition-all delay-150 duration-500 absolute z-10 #{min_width} text-xs font-medium leading-none whitespace-no-wrap text-white p-2 opacity-0 group-hover:opacity-95 invisible group-hover:visible bg-gray-800 shadow-lg rounded-md"}>
        <%= @text %>
      </span>
    </div>
    """
  end

  @spec info_header(map()) :: Phoenix.LiveView.Rendered.t()
  def info_header(assigns) do
    assigns = assign_class(assigns)

    ~H"""
    <div class={"flex mb-3 #{@class}"}>
      <h3 class="subheader mr-1"><%= @title %></h3>
      <.tooltip
        text={@tooltip}
        class="bottom-8 -right-16 text-center w-40"
        min_width="min-w-fit"
      >
        <.info_icon />
      </.tooltip>
    </div>
    """
  end

  defp assign_class(assigns) do
    assign_new(assigns, :class, fn -> "" end)
  end
end
