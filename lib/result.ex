defmodule Result do
  @type winner :: Player.t()
  @type tie :: :tie

  @type t :: winner() | tie()

  @spec tie() :: tie()
  def tie(), do: :tie

  @spec print(t()) :: String.t()
  def print(:tie) do
    'Tie'
  end

  def print(%Player{name: name, hand: hand}) do
    "#{name} wins - #{hand_rank(HandRank.of(hand))}"
  end

  @spec hand_rank(HandRank.t()) :: String.t()
  defp hand_rank(%HandRank{name: name, point: point}) do
    name = name |> Atom.to_string() |> String.replace("_", " ")

    point = point |> Enum.at(0) |> Map.get(:rank)

    "#{name}: #{point}"
  end
end
