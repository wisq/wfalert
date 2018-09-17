import WFAlert.Filter.Helpers

owned_helmets =
  [
    "Banshee Reverb",
    "Ember Backdraft",
    "Ember Phoenix",
    "Excalibur Pendragon",
    "Excalibur Umbra Sunder",
    "Hydroid Triton",
    "Inaros Canopic",
    "Ivara Loxley",
    "Ivara Zirastra",
    "Limbo Magrite",
    "Loki Essence",
    "Mag Coil",
    "Mesa Ovis",
    "Mirage Harlequin",
    "Nezha Jinza",
    "Nova Device",
    "Nova Quantum",
    "Nova Slipstream",
    "Nyx Vespa",
    "Oberon Markhor",
    "Oberon Oryx",
    "Revenant Vania",
    "Saryn Chlora",
    "Saryn Hemlock",
    "Titania Aurai",
    "Trinity Aura",
    "Trinity Meridian",
    "Valkyr Bastet",
    "Vauban Armistice",
    "Wukong Macak",
    # Helmets incorrectly named in the item table:
    #   Should be "Frost Aurora".
    "Aurora Frost"
  ]
  |> Enum.map(&"#{&1} Helmet Blueprint")

alert_filters([
  # Ignore credits.
  by_category(:drop_item, :credits),
  # Ignore helmets I own.
  by_category_and_name(:drop_item, :helmet_blueprint, owned_helmets),
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
  # Show everything else (if there's un-dropped rewards left).
  default(:show)
])
