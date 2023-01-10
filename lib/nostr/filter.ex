defmodule NostrTools.Filter do
  @moduledoc """
  Defines a Nostr Filter struct and related functions. Can be serialized to json with Jason
  """

  alias NostrTools.Event


  @type t() :: %__MODULE__{
          ids: [String.t()] | nil,
          authors: [String.t()] | nil,
          kinds: [non_neg_integer()] | nil,
          e: [String.t()] | nil,
          p: [String.t()] | nil,
          since: non_neg_integer() | nil,
          until: non_neg_integer() | nil,
          limit: non_neg_integer() | nil
        }

  defstruct [
    :ids,
    :authors,
    :kinds,
    :e,
    :p,
    :since,
    :until,
    :limit
  ]

  @doc """
  Checks if a filter matches an event

  Not Implemented
  """
  @spec matches?(filter :: t(), event :: Event.t()) :: boolean()
  def matches? _filter, _event do
    false
  end

end

defimpl Jason.Encoder, for: NostrTools.Filter do
  def encode(%NostrTools.Filter{} = filter, opts) do
    filter
    |> Map.delete(:__struct__)
    |> Map.to_list()
    |> Enum.filter(fn {_k, v} -> v != nil end)
    |> Map.new()
    |> Jason.Encode.map(opts)
  end
end
