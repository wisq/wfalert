# WFAlert

WFAlert monitors alerts and invasions in [Warframe](https://www.warframe.com/), applies highly customisable filters, and delivers them to your mobile device using [Pushover](https://pushover.net/).

## Intended audience

This project assumes some basic knowledge of programming.  Specifically, the configuration file is written in [Elixir](https://elixir-lang.org/), and you'll need some basic technical knowhow to install the dependencies and get it going.

I wrote WFAlert because I wanted more precise filtering, and the simplest way to do that (for me) was to have the config file be written in actual code.  This allows me to do pretty much any logic I want, no matter how complex.

If you're just looking for an easy way to monitor alerts and invasions, you're probably in the wrong place; there are simpler apps that will do that for you.  (Previously, I used [Alerts for Warframe](https://itunes.apple.com/ca/app/alerts-for-warframe/id775981113?mt=8) on my iPhone.)

## Usage

* `mix wfalert.alerts [config file]`
  * Shows a list of current alerts, and whether they match or not.
  * Includes extra data (like raw internal item IDs) that you can potentially use for filters.
* `mix wfalert <config file>`
  * Checks current alerts and invasions, and sends messages for new ones.
  * Uses filters from the config file to limit which items are sent.
  * Will only check each alert or invasion once, so no repeats.

## Installation

1. Install [Elixir](https://elixir-lang.org/install.html).  Ensure that the `mix` command works and is in your `$PATH` (or equivalent).
2. `git clone` this repository and change to its directory.
3. Run `mix deps.get` to fetch dependencies.
4. Ensure that `mix wfalert.alerts` works and shows current alerts.

### Set up filters

1. Create a config file.
    * For my own personal config, see `wisq/filters.exs`; you can base yours on that.
    * See [Filter logic](#filter-logic) below.
2. Run `mix wfalert.alerts <path to your config file>` and ensure the current alerts are filtered the way you want.

### Set up notifications

1. Create a [Pushover](https://pushover.net/) account.
2. Within Pushover, [create an application](https://pushover.net/apps/build).
    * You can give it an icon; I recommend searching Google Images for "Warframe logo" and picking something simple, and with a transparent background.
3. Copy `config/pushover.example.exs` to `config/pushover.exs` and fill in your Pushover keys.
    * The API token is the token for your app.
    * The user key is your user key, from the main Pushover page after logging in.
4. Set up some sort of periodic script (e.g. `cron`, `runit`, `systemd`, etc.) to run `mix wfalert <path to your config file>` on a regular basis.
    * You may want to do a few manual test runs first.  When you do, make sure at least one alert or invasion matches your filters.

## Filter logic

Alerts and invasions are filtered separately.  For each alert or invasion, the filter lists are processed in order from top to bottom.  There are currently three supported actions:

* `:hide` — If any reward matches this condition, the current alert/invasion **will not** trigger a notification.  Processing stops.
* `:show` — If any reward matches this condition, the current alert/invasion **will** trigger a notification.  Processing stops.
* `:drop_item` — If any reward matches this condition, that reward is removed.
  * Future filters will not take this reward into account when making their decisions.
  * If all rewards are dropped in this way, this triggers the `:hide` behaviour, and processing stops.
  * Note that dropped rewards *will* still show up on notifications; this only affects *filtering*, not notifying.

Various functions can be used to apply these filters:

* `default(action)` — Matches all rewards.
  * Any alert/invasion that makes it this far will immediately trigger `action`.
  * As such, this is only useful as the last rule in a filter chain.
* `by_id(action, id)` — Matches by raw (internal) item ID.
* `by_category(action, category)` — Matches by category.
* `by_name(action, name)` — Matches by name.
* `by_category_and_name(action, category, name)` — Matches by category and name (both must match).

For `id`, `category`, and `name`, several different values can be used:

* If the value is a string, it must match exactly (case insensitive).
* If the value is a regular expression (regex), it must match.
  * You can control parameters like case-sensitivity via the [regex syntax](https://hexdocs.pm/elixir/Regex.html).
* If the value is an atom (e.g. for `category`), it must match exactly.
* If the value is a list, then each element of the list can be any of the above.
  * The value will be considered to match if the item matches **any** member of the list.

There are also some helper functions included:

* `read_lines(file)` — Read all lines from `file` and return a list.
  * You can use this to store lengthy lists (e.g. "items I own") in an external text file.
  * Blank lines, and comments (lines starting with `#`), are ignored.
  * The filename is resolved relative to the calling file.  E.g. if `x/filters.exs` calls `read_lines("y/z.txt")`, the target file is `x/y/z.txt`.

## Example

<img width="375" height="812" src="https://i.wisq.net/IMG_0628-20180919-212634.jpg" />
