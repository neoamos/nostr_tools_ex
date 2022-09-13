defmodule Nostr.Tag do
  @moduledoc false

  @enforce_keys [:type, :content]
  defstruct type: nil,
            content: nil,
            recomended_relay: nil

  @type tag_type() :: :event | :pubkey
  @type t() :: %__MODULE__{
          type: tag_type(),
          content: Secp256k1.pubkey() | binary(),
          recomended_relay: String.t() | nil
        }

  @spec event(event_id :: Nostr.Event.id(), recomended_relay :: String.t() | nil) :: t()
  def event(event_id, recomended_relay \\ nil) do
    %__MODULE__{
      type: :event,
      content: event_id,
      recomended_relay: recomended_relay
    }
  end

  @spec pubkey(pubkey :: Secp256k1.pubkey(), recomended_relay :: String.t() | nil) :: t()
  def pubkey(pubkey, recomended_relay \\ nil) do
    %__MODULE__{
      type: :pubkey,
      content: pubkey,
      recomended_relay: recomended_relay
    }
  end

  @spec serialize_type(tag_type :: tag_type()) :: <<_::8>>
  def serialize_type(:event), do: "e"
  def serialize_type(:pubkey), do: "p"
end

defimpl Jason.Encoder, for: Nostr.Tag do
  def encode(%Nostr.Tag{} = tag, opts) do
    [
      Nostr.Tag.serialize_type(tag.type),
      tag.type,
      tag.recomended_relay
    ]
    |> Jason.Encode.list(opts)
  end
end
