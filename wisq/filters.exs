import WFAlert.Helpers.RewardFilter
alias WFAlert.Helpers.FissureFilter, as: F
import WFAlert.Helpers.Utility

owned_helmets =
  read_lines("lists/owned_helmets.txt")
  |> Enum.map(&~r{^#{&1} Helmet( Blueprint)?})

owned_weapons =
  read_lines("lists/owned_weapons.txt")
  |> Enum.map(&"#{&1} Blueprint")

owned_weapon_skins =
  read_lines("lists/owned_weapon_skins.txt")
  |> Enum.map(&"#{&1} Skin Blueprint")

owned_weapon_parts =
  read_lines("lists/owned_weapons.txt")
  |> Enum.map(&~r{^#{&1} [A-Z][a-z]+$})

owned_nightmare_mods = read_lines("lists/owned_nightmare_mods.txt")
owned_aura_mods = read_lines("lists/owned_aura_mods.txt")

# Ignore certain resources in their standard quantities.
# If they increase the amounts later, maybe I'll be interested.
unneeded_resources = %{
  "Alloy Plate" => 1500,
  "Argon Crystal" => 1,
  "Circuits" => 1500,
  "Control Module" => 1,
  "Ferrite" => 3000,
  "Gallium" => 1,
  "Morphics" => 1,
  "Nano Spores" => 3000,
  "Neural Sensors" => 1,
  "Neurodes" => 1,
  "Nitain Extract" => 1,
  "Orokin Cell" => 1,
  "Oxium" => 300,
  "Plastids" => 300,
  "Polymer Bundle" => 300,
  "Rubedo" => 450,
  "Salvage" => 300,
  "Synthula" => 5,
  "Tellurium" => 1,
  "Void Traces" => 20
}

alert_filters([
  # Ignore credits, Endo, etc.
  by_category(:drop_item, [:credits, :endo]),
  # Ignore certain resources in their standard quantities.
  filter(:drop_item, fn r ->
    r.category == :resource && r.quantity <= Map.get(unneeded_resources, r.name, -1)
  end),
  # Ignore items I own.
  by_category_and_name(:drop_item, :helmet_blueprint, owned_helmets),
  by_category_and_name(:drop_item, :blueprint, owned_weapons),
  by_category_and_name(:drop_item, :blueprint, owned_weapon_skins),
  by_category_and_name(:drop_item, :mod, owned_nightmare_mods),
  by_category_and_name(:drop_item, :aura_mod, owned_aura_mods),
  # Ignore Vauban.
  by_category_and_name(:drop_item, :warframe_blueprint, ~r{^Vauban .* [bB]lueprint}),
  # Show everything else (if there's un-dropped rewards left).
  default(:show)
])

# Be careful using :hide here.
# You may hide an entire invasion just based on ONE of the rewards.
invasion_filters([
  # Three runs for one mutagen mass is awful, so two is ideal.
  # But, I have enough of these for a while.
  # filter(:show, fn r -> r.name == "Mutagen Mass" && r.quantity >= 2 end),
  # Don't care much about fieldrons or detonites.
  by_category(:drop_item, :crafting_part),
  # Ignore parts for weapons I own.
  by_category_and_name(:drop_item, :weapon_part, owned_weapon_parts),
  # Let's show everything else.
  default(:show)
])

F.fissure_filters([
  F.by_mission_type(:show, :excavation),
  F.default(:hide)
])
