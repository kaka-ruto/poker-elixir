defmodule CardTest do
  use ExUnit.Case
  doctest Card

  @consecutive_pairs [
    {2, 3},
    {3, 4},
    {4, 5},
    {5, 6},
    {6, 7},
    {7, 8},
    {8, 9},
    {9, 10},
    {10, :jack},
    {:jack, :queen},
    {:queen, :king},
    {:king, :ace}
  ]

  describe "greater_than?/2" do
    test "true when the card is greater than the other" do
      @consecutive_pairs
      |> Enum.each(fn {rank, consecutive_higher_rank} ->
        assert Card.greater_than?(Card.clubs_of(consecutive_higher_rank), Card.clubs_of(rank))
      end)
    end

    test "false when the card is not greater than the other" do
      @consecutive_pairs
      |> Enum.each(fn {rank, consecutive_higher_rank} ->
        refute Card.greater_than?(Card.clubs_of(rank), Card.clubs_of(consecutive_higher_rank))
      end)
    end
  end

  describe "consecutive_rank?/2" do
    test "true when the cards are consecutive to each other" do
      @consecutive_pairs
      |> Enum.each(fn {rank, consecutive_higher_rank} ->
        assert Card.consecutive_rank?(Card.clubs_of(rank), Card.clubs_of(consecutive_higher_rank))
      end)
    end
  end
end
