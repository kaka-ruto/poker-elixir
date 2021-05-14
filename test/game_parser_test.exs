defmodule GameParserTest do
  use ExUnit.Case

  describe "parse/1" do
    test "returns a list of players" do
      [first_player, second_player] =
        GameParser.parse("Player Marco: 2H 3D 5S 9C KD  Player Polo: 3H 3D 5S 9C KD")

      assert first_player == %Player{
               name: "Player Marco",
               hand: %Hand{
                 cards: [
                   Card.hearts_of(2),
                   Card.diamonds_of(3),
                   Card.spades_of(5),
                   Card.clubs_of(9),
                   Card.diamonds_of(:king)
                 ]
               }
             }

      assert second_player == %Player{
               name: "Player Polo",
               hand: %Hand{
                 cards: [
                   Card.hearts_of(3),
                   Card.diamonds_of(3),
                   Card.spades_of(5),
                   Card.clubs_of(9),
                   Card.diamonds_of(:king)
                 ]
               }
             }
    end
  end

  describe "parse_player/1" do
    test "creates a Player with its Hand from a String" do
      player = GameParser.parse_player("A Player: 2H 3D 5S 9C KD")

      assert player == %Player{
               name: "A Player",
               hand: %Hand{
                 cards: [
                   Card.hearts_of(2),
                   Card.diamonds_of(3),
                   Card.spades_of(5),
                   Card.clubs_of(9),
                   Card.diamonds_of(:king)
                 ]
               }
             }
    end
  end
end
