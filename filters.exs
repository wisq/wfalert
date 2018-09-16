import WFAlert.Filter.Helpers

alert_filters([
  filter_category(:ignore, :credits),
  default(:hide)
])

invasion_filters([
  filter(:show, fn r -> r.name == "Mutagen Mass" && r.quantity >= 2 end),
  default(:hide)
])
