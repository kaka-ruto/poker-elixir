defmodule HandRank do
  @type name :: :high_card | :one_pair | :two_pair | :three_of_kind | :straight |
                :flush | :fullhouse | :four_of_kind | :straight_flush | :royal_flush

  @type point :: list(Card.t())
  @type t :: %__MODULE__{name: name(), point: point()}

  defstruct [:name, :point]

  @spec compare(t(), t()) :: {:first, t()} | {:second, t()} | :tie
  def compare(rank, other_rank) do
    cond do
      greater_than?(rank, other_rank) -> { :first, rank }
    
      greater_than?(other_rank, rank) -> { :second, other_rank }

      true -> compare_by_highest_card(rank, other_rank)
    end
  end

  @spec greater_than?(t(), t()) :: boolean()
  defp greater_than?(rank, other_rank) do
    to_integer(rank) > to_integer(other_rank)
  end

  @spec to_integer(t()) :: integer()
  defp to_integer(%__MODULE__{name: :high_card}), do: 1
  defp to_integer(%__MODULE__{name: :one_pair}), do: 2
  defp to_integer(%__MODULE__{name: :two_pair}), do: 3
  defp to_integer(%__MODULE__{name: :three_of_kind}), do: 4
  defp to_integer(%__MODULE__{name: :straight}), do: 5
  defp to_integer(%__MODULE__{name: :flush}), do: 6
  defp to_integer(%__MODULE__{name: :fullhouse}), do: 7
  defp to_integer(%__MODULE__{name: :four_of_kind}), do: 8
  defp to_integer(%__MODULE__{name: :straight_flush}), do: 9
  defp to_integer(%__MODULE__{name: :royal_flush}), do: 10

  @spec compare_by_highest_card(t(), t()) :: {:first, t()} | {:second, t()} | :tie
  defp compare_by_highest_card(rank, other_rank) do
    card = Cards.highest_card(rank.point)
    other_card = Cards.highest_card(other_rank.point)
    
    cond do
      Card.greater_than?(card, other_card) -> { :first, rank }
         
      Card.greater_than?(other_card, card) -> { :second, other_rank }

      true -> :tie
    end
  end

  @spec of(Hand.t()) :: t()
  def of(%Hand{cards: cards}) do
    has_point? = fn hand_rank -> hand_rank.point != [] end

    [
      &royal_flush_from/1,
      &straight_flush_from/1,
      &four_of_kind_from/1,
      &fullhouse_from/1,
      &flush_from/1,
      &straight_from/1,
      &three_of_kind_from/1,
      &two_pair_from/1,
      &one_pair_from/1,
      &highest_card_from/1
    ]
    |> match_first(on: cards, until: has_point?)
  end

  defp match_first([predicate | other_predicates], on: element, until: condition) do
    result = predicate.(element)

    case condition.(result) do
      true -> result

      _ -> match_first(other_predicates, on: element, until: condition)
    end
  end

  defp match_first(_predicates = [], on: _element, until: _condition) do
    nil
  end

  defp royal_flush_from(cards) do
    straight_flush = straight_flush_from(cards)

    point = case has_point?(straight_flush) and Cards.any(straight_flush.point, :ace) do
      true -> straight_flush.point

      false -> []
    end

    to_hand_rank(point, :royal_flush)
  end

  defp straight_flush_from(cards) do
    straight = straight_from(cards)
    flush = flush_from(cards)

    point = case straight.point ==  Cards.sort_by_rank(flush.point) do
      true -> straight.point

      false -> []
    end

    to_hand_rank(point, :straight_flush)
  end

  defp four_of_kind_from(cards) do
    cards
    |> group_cards_by_same_rank()
    |> with_a_number_of_cards(4)
    |> to_hand_rank(:four_of_kind)
  end

  defp fullhouse_from(cards) do
    three_of_kind = three_of_kind_from(cards)
    one_pair = one_pair_from(cards)

    point = case has_point?(three_of_kind) && has_point?(one_pair) do
      true -> three_of_kind.point ++ one_pair.point

      false -> []
    end

    to_hand_rank(point, :fullhouse)
  end

  defp flush_from(cards) do
    cards
    |> all_cards_with(&Card.same_suit?/2)
    |> to_hand_rank(:flush)
  end

  defp straight_from(cards) do
    cards
    |> Cards.sort_by_rank()
    |> all_cards_with(&Card.consecutive_rank?/2)
    |> to_hand_rank(:straight)
  end

  defp three_of_kind_from(cards) do
    cards
    |> group_cards_by_same_rank()
    |> with_a_number_of_cards(3)
    |> to_hand_rank(:three_of_kind)
  end

  defp two_pair_from(cards) do
    cards
    |> group_cards_by_same_rank()
    |> with_a_number_of_cards(2)
    |> with_total_number_of_cards(4)
    |> to_hand_rank(:two_pair)
  end

  defp one_pair_from(cards) do
    cards
    |> group_cards_by_same_rank()
    |> with_a_number_of_cards(2)
    |> to_hand_rank(:one_pair)
  end

  defp highest_card_from(cards) do
    high_card = Cards.highest_card(cards)

    to_hand_rank([high_card], :high_card)
  end

  @spec to_hand_rank(point(), name()) :: t()
  defp to_hand_rank(point, name) do
    %__MODULE__{name: name, point: point}
  end

  @spec has_point?(t()) :: boolean()
  defp has_point?(%__MODULE__{point: []}), do: false
  defp has_point?(_), do: true

  defp group_cards_by_same_rank(cards) do
    cards
    |> Enum.group_by(fn %Card{rank: rank} -> rank end)
    |> Enum.map(fn {_, cards_with_same_rank} -> cards_with_same_rank end)
  end

  defp with_a_number_of_cards(cards_grouped_by_rank, number_of_cards) do
    cards_grouped_by_rank
    |> Enum.filter(fn cards -> length(cards) == number_of_cards end)
    |> Enum.concat()
  end

  defp with_total_number_of_cards(cards, number_of_cards) do
    case length(cards) do
      ^number_of_cards -> cards

      _ -> []
    end
  end

  defp all_cards_with(cards, compare) do
    all_matches? = cards
                   |> Enum.chunk_every(2, 1, :discard)
                   |> Enum.all?(fn [card, next_card] -> compare.(card, next_card) end)

    case all_matches? do
      true -> cards

      false -> []
    end
  end
end
