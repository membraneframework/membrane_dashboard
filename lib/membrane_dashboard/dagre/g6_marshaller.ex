defmodule Membrane.Dashboard.Dagre.G6Marshaller do
  @moduledoc """
  This module is responsible for marshalling data regarding links between membrane elements
  to create a structure suitable for generating a dagre layout (directed graph) using a `G6` library
  whose documentation is available at [https://g6.antv.vision/en/docs/api/graphLayout/dagre].

  The resulting structure is a JSON document having 3 arrays, each for a different type:
  - nodes
  - edges
  - combos

  While what is a node and an edge is clear, combo is a group of nodes which can be again nested to become a group of combos.
  It gives a visual effect of a box with all declared nodes being inside of it. Nodes are firstly grouped into pipelines, then they can be
  again grouped but this time in bins which are nested inside pipelines ect.

  This module takes into account the elements' liveness and accordingly assigns the nodes with proper colors.
  Colors differ depending on what state the node currently is in. If it belongs to already existing elements' group, it will have a darker color. If it has
  just been created it will have a brighter color.

  One can distinguish 2 types of nodes:
  - element nodes
  - bin's nodes
  Bin's nodes have different colors and represent bin's internal linking points while element nodes represent simple elements (sources, filters, sinks).

  """

  require Logger

  @type link_t :: %{
          parent_path: String.t(),
          from: String.t(),
          to: String.t(),
          pad_from: String.t(),
          pad_to: String.t()
        }

  @bin_itself "{Membrane.Bin, :itself}"

  @new_bin_node_style %{
    fill: "#ffb700"
  }

  @dead_bin_node_style %{
    fill: "#730000"
  }

  @existing_bin_node_style %{
    fill: "#ad8110"
  }

  @new_node_style %{
    fill: "#14fa14"
  }
  @dead_node_style %{
    fill: "#ff5559"
  }
  @existing_node_style %{
    fill: "#166e15"
  }

  @default_node_style %{}

  @spec run(
          [link_t()],
          elements_liveliness :: %{new: MapSet.t(), dead: MapSet.t(), existing: MapSet.t()}
        ) :: {:ok, any()} | {:error, any()}
  def run(links, elements_liveliness) do
    bin_nodes = collect_bin_nodes(links)

    result =
      links
      |> Enum.map(fn link -> format_link(link, bin_nodes) end)
      |> Enum.reduce(
        %{nodes: MapSet.new(), edges: MapSet.new(), combos: MapSet.new()},
        &reduce_link/2
      )

    nodes = colorize_nodes(result.nodes, elements_liveliness)

    {:ok, %{result | nodes: nodes}}
  end

  defp format_link(link, bin_nodes) do
    parents = link.parent_path |> String.split("/")

    last_parent = parents |> List.last()

    {from_is_bin, from_path} = element_path(link.parent_path, parents, link.from, bin_nodes)
    {to_is_bin, to_path} = element_path(link.parent_path, parents, link.to, bin_nodes)

    from = format_element(last_parent, link.from, link.pad_from, from_is_bin)
    to = format_element(last_parent, link.to, link.pad_to, to_is_bin)

    link
    |> Map.merge(%{
      from: from,
      from_node: generate_node(from_path, from),
      from_path: from_path,
      from_is_bin: from_is_bin,
      to: to,
      to_node: generate_node(to_path, to),
      to_path: to_path,
      to_is_bin: to_is_bin
    })
  end

  defp reduce_link(link, %{nodes: nodes, edges: edges, combos: combos}) do
    {from_combo, to_combo} = link_combos(link)

    %{
      nodes:
        nodes
        # put 'from' node
        |> MapSet.put(%{
          id: link.from_node,
          label: link.from,
          comboId: from_combo.id,
          is_bin: link.from_is_bin,
          path: link.from_path ++ [link.from]
        })
        # put 'to' node
        |> MapSet.put(%{
          id: link.to_node,
          label: link.to,
          comboId: to_combo.id,
          is_bin: link.to_is_bin,
          path: link.to_path ++ [link.to]
        }),
      edges:
        edges
        |> MapSet.put(%{
          source: link.from_node,
          target: link.to_node
        }),
      combos: combos |> MapSet.put(from_combo) |> MapSet.put(to_combo)
    }
  end

  defp collect_bin_nodes(links) do
    links
    |> Enum.map(& &1.parent_path)
    |> Enum.filter(&String.ends_with?(&1, " bin"))
    |> MapSet.new()
  end

  # returns 'from' and 'to' elements combos
  defp link_combos(link) do
    from_combo = combo(link.from_path)
    to_combo = combo(link.to_path)

    {from_combo, to_combo}
  end

  defp combo(path) do
    id = path |> Enum.join() |> hash_string()
    [label | parents] = path |> Enum.reverse()

    parent_id =
      if parents == [] do
        nil
      else
        parents |> Enum.reverse() |> Enum.join() |> hash_string()
      end

    %{
      id: id,
      label: label,
      parentId: parent_id,
      path: path
    }
  end

  defp colorize_nodes(nodes, elements_liveliness) do
    nodes
    |> Enum.map(fn %{path: path, is_bin: is_bin} = node ->
      path =
        if is_bin do
          path |> Enum.reverse() |> tl() |> Enum.reverse()
        else
          path
        end

      path_str = Enum.join(path, "/")

      style = select_path_style(path_str, is_bin, elements_liveliness)

      Map.put(node, :style, style)
    end)
  end

  defp select_path_style(path, is_bin, %{dead: dead, new: new, existing: existing}) do
    cond do
      MapSet.member?(dead, path) ->
        if is_bin, do: @dead_bin_node_style, else: @dead_node_style

      MapSet.member?(new, path) ->
        if is_bin, do: @new_bin_node_style, else: @new_node_style

      MapSet.member?(existing, path) ->
        if is_bin, do: @existing_bin_node_style, else: @existing_node_style

      true ->
        Logger.warn("#{path} has not been found among queried elements...")

        @default_node_style
    end
  end

  defp format_element(last_parent, @bin_itself, pad, _is_bin),
    do: String.replace_suffix(last_parent, " bin", "") <> "\n" <> pad

  defp format_element(_last_parent, element, pad, true), do: element <> "\n" <> pad
  defp format_element(_last_parent, element, _pad, false), do: element

  defp generate_node(path, element),
    do: "#{path |> Enum.join()}#{element}" |> hash_string()

  defp hash_string(to_hash),
    do: to_hash |> :erlang.md5() |> Base.encode16()

  # element_path is responsible for retrieving element path
  # it has to be changed in case given element is a bin itself
  defp element_path(_parent_path, parents, @bin_itself, _bin_nodes) do
    {true, parents}
  end

  defp element_path(parent_path, parents, element, bin_nodes) do
    element_bin = "#{element} bin"
    bin_path = "#{parent_path}/#{element_bin}"

    if MapSet.member?(bin_nodes, bin_path) do
      {true, parents ++ [element_bin]}
    else
      {false, parents}
    end
  end
end
