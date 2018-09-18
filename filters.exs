import WFAlert.Filter.Helpers

owned_helmets =
  read_lines("lists/owned_helmets.txt")
  |> Enum.map(&~r{^#{&1} Helmet( Blueprint)?})

owned_weapons =
  read_lines("lists/owned_weapons.txt")
  |> Enum.map(&"#{&1} Blueprint")

owned_nightmare_mods = read_lines("lists/owned_nightmare_mods.txt")

# Ignore certain resources in their standard quantities.
# If they increase the amounts later, maybe I'll be interested.
unneeded_resources = %{
  "Rubedo" => 450,
  "Morphic" => 1,
  "Control Module" => 1,
  "Argon Crystal" => 1,
  "Plastids" => 300,
  "Void Traces" => 20,
  "Tellurium" => 1
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
  by_category_and_name(:drop_item, :mod, owned_nightmare_mods),
  # Ignore Vauban.
  by_category_and_name(:drop_item, :warframe_blueprint, ~r{^Vauban .* [bB]lueprint}),
  # Show everything else (if there's un-dropped rewards left).
  default(:show)
])

# Be careful using :hide here.
# You may hide an entire invasion just based on ONE of the rewards.
invasion_filters([
  # Three runs for one mutagen mass is awful, so two is ideal.
  filter(:show, fn r -> r.name == "Mutagen Mass" && r.quantity >= 2 end),
  # Don't care much about fieldrons or detonites.
  by_category(:drop_item, :crafting_part),
  # For now, I'm hiding everything else.
  default(:hide)
])
