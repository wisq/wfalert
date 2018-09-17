defmodule WFAlert.Filter do
  @enforce_keys [:action, :condition]
  defstruct(
    action: nil,
    condition: nil
  )

  defmodule State do
    @enforce_keys [:rewards]
    defstruct(
      rewards: nil,
      action: nil
    )
  end

  # No filters, so it passes.
  def match?([], rewards), do: true

  def match?(filters, rewards) do
    initial = %State{rewards: rewards}
    final = Enum.reduce_while(filters, initial, &reduce_filter/2)

    case final.action do
      :show -> true
      :hide -> false
    end
  end

  # No rewards left (all dropped), so hide it.
  defp reduce_filter(_filter, %State{rewards: []} = state) do
    {:halt, %State{state | action: :hide}}
  end

  defp reduce_filter(filter, state) do
    state = Enum.reduce_while(state.rewards, state, &reduce_reward(filter, &1, &2))

    if state.action do
      {:halt, state}
    else
      {:cont, state}
    end
  end

  defp reduce_reward(filter, reward, state) do
    if filter.condition.(reward) do
      apply_action(filter.action, reward, state)
    else
      {:cont, state}
    end
  end

  defp apply_action(action, reward, state) do
    case action do
      :drop_item ->
        state = %State{state | rewards: List.delete(state.rewards, reward)}

        if Enum.empty?(state.rewards) do
          {:halt, state}
        else
          {:cont, state}
        end

      action when is_atom(action) ->
        state = %State{state | action: action}
        {:halt, state}
    end
  end
end
