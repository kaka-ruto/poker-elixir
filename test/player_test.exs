defmodule PlayerTest do
  use ExUnit.Case

  describe "play_against/2" do
    test "returns the player that has the winning poker hand" do
      winner = %Player{name: "Marco", hand: royal_flush()}
      runners_up = %Player{name: "Polo", hand: high_card()}

      assert Player.play_against(winner, runners_up) == winner
      assert Player.play_against(runners_up, winner) == winner
    end

    test "returns tie when players score equally" do
      marco = %Player{name: "Marco", hand: high_card()}
      polo = %Player{name: "Polo", hand: high_card()}

      assert Player.play_against(marco, polo) == :tie
      assert Player.play_against(polo, marco) == :tie
    end
  end

  defp royal_flush() do
    Hand.with([
      Card.hearts_of(10),
      Card.hearts_of(:jack),
      Card.hearts_of(:queen),
      Card.hearts_of(:king),
      Card.hearts_of(:ace)
    ])
  end

  defp high_card() do
    Hand.with([
      Card.clubs_of(5),
      Card.hearts_of(:jack),
      Card.hearts_of(:queen),
      Card.diamonds_of(:king),
      Card.hearts_of(:ace)
    ])
  end
end
