import WFAlert.Filter.Helpers

owned_helmets =
  read_lines("lists/owned_helmets.txt")
  |> Enum.map(&"#{&1} Helmet Blueprint")

alert_filters([
  # Ignore credits.
  by_category(:drop_item, :credits),
  # Ignore certain resources in their standard quantities.
  # If they increase the amounts later, maybe I'll be interested.
  filter(:drop_item, fn r -> r.name == "Rubedo" && r.quantity <= 450 end),
  filter(:drop_item, fn r -> r.name == "Morphic" && r.quantity <= 1 end),
  # Ignore helmets I own.
  by_category_and_name(:drop_item, :helmet_blueprint, owned_helmets),
  # Ignore Vauban.
  by_category_and_name(:drop_item, :warframe_blueprint, ~r{^Vauban .* Blueprint}),
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
