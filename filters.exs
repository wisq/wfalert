import WFAlert.Filter.Helpers

alert_filters([
  filter_category(:drop_item, :credits),
  default(:show)
])

invasion_filters([
  filter(:show, fn r -> r.name == "Mutagen Mass" && r.quantity >= 2 end),
  filter_category(:hide, :crafting_part),
  default(:show)
])
