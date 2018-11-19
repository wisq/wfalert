defmodule WFAlert.Fissure do
  alias WFAlert.{Fissure, FissureFilter, Nodes}
  import WFAlert.Util, only: [parse_time: 1]
  require Logger

  @enforce_keys [:id, :expires, :tier, :node, :planet, :mission_type, :relic_type]
  defstruct(
    id: nil,
    starts: nil,
    expires: nil,
    tier: nil,
    node: nil,
    planet: nil,
    mission_type: nil,
    relic_type: nil
  )

  def parse(blob) do
    starts = Map.fetch!(blob, "Activation") |> parse_time()
    expires = Map.fetch!(blob, "Expiry") |> parse_time()

    mission = Map.fetch!(blob, "MissionType") |> parse_mission_type()
    {tier, relic} = Map.fetch!(blob, "Modifier") |> parse_modifier()
    {node, planet} = Map.fetch!(blob, "Node") |> Nodes.node_and_planet()

    %Fissure{
      id: id(blob),
      starts: starts,
      expires: expires,
      tier: tier,
      node: node,
      planet: planet,
      mission_type: mission,
      relic_type: relic
    }
  end

  def sort(fissures) do
    Enum.sort_by(fissures, fn f -> [f.tier, f.id] end)
  end

  def match?(fissure) do
    FissureFilter.match?(
      Application.get_env(:wfalert, :fissure_filters, []),
      fissure
    )
  end

  def started?(fissure) do
    DateTime.utc_now() |> DateTime.compare(fissure.starts) == :gt
  end

  def expired?(fissure) do
    DateTime.utc_now() |> DateTime.compare(fissure.expires) == :lt
  end

  def one_line(f) do
    expiry = time_to_expire(f) |> seconds_to_string()
    mission = f.mission_type |> show_mission_type()
    relic = f.relic_type |> show_relic_type()
    "#{relic} — #{f.node} (#{f.planet}) - #{mission} – #{expiry}"
  end

  defp id(%{"_id" => %{"$oid" => hex}}), do: hex

  defp time_to_expire(fissure) do
    DateTime.diff(fissure.expires, DateTime.utc_now())
  end

  defp seconds_to_string(s) when abs(s) >= 3600 do
    h = div(s, 3600)
    m = abs(s) |> rem(3600) |> div(60)
    "#{h}h#{m}m"
  end

  defp seconds_to_string(s) when abs(s) >= 60 do
    m = div(s, 60)
    "#{m}m"
  end

  @mission_types %{
    "MT_EXCAVATE" => :excavation,
    "MT_SABOTAGE" => :sabotage,
    "MT_MOBILE_DEFENSE" => :mobile_defense,
    "MT_ASSASSINATION" => :assassination,
    "MT_EXTERMINATION" => :extermination,
    "MT_HIVE" => :hive,
    "MT_DEFENSE" => :defense,
    "MT_TERRITORY" => :interception,
    "MT_ARENA" => :rathuum,
    "MT_PVP" => :conclave,
    "MT_RESCUE" => :rescue,
    "MT_INTEL" => :spy,
    "MT_SURVIVAL" => :survival,
    "MT_CAPTURE" => :capture,
    "MT_SECTOR" => :dark_sector,
    "MT_RETRIEVAL" => :hijack,
    "MT_ASSAULT" => :assault,
    "MT_EVACUATION" => :defection,
    "MT_LANDSCAPE" => :free_roam
  }

  defp parse_mission_type(str) do
    case Map.fetch(@mission_types, str) do
      {:ok, type} ->
        type

      :error ->
        Logger.warn("Unknown mission type: #{inspect(str)}")
        :unknown
    end
  end

  defp parse_modifier("VoidT1"), do: {1, :lith}
  defp parse_modifier("VoidT2"), do: {2, :meso}
  defp parse_modifier("VoidT3"), do: {3, :neo}
  defp parse_modifier("VoidT4"), do: {4, :axi}

  defp show_mission_type(type) do
    type
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp show_relic_type(type) do
    type
    |> Atom.to_string()
    |> String.capitalize()
  end
end
