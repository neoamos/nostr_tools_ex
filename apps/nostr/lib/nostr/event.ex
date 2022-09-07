defmodule Nostr.Event do
  @moduledoc false

  @enforce_keys [:pubkey, :created_at, :kind, :content]
  defstruct id: :not_loaded,
            pubkey: nil,
            created_at: nil,
            kind: nil,
            tags: [],
            content: nil,
            sig: :not_loaded

  @type kind() :: :set_metadata | :text_note | :recommend_server
  @type tag() :: [String.t()]

  @type t() :: %__MODULE__{
          id: <<_::32, _::_*8>> | :not_loaded,
          pubkey: <<_::32, _::_*8>>,
          created_at: DateTime.t(),
          kind: kind(),
          tags: [tag()],
          content: String.t() | map(),
          sig: <<_::64, _::_*8>> | :not_loaded
        }

  def gen_id(%__MODULE__{} = event) do
    {:ok, encoded} =
      Jason.encode([
        0,
        Base.encode16(event.pubkey),
        DateTime.to_unix(event.created_at),
        serialize_kind(event.kind),
        event.tags,
        event.content
      ])

    :sha256
    |> :crypto.hash(encoded)
    |> Base.encode16(case: :lower)
  end

  def load_id(%__MODULE__{} = event) do
    %__MODULE__{event | id: gen_id(event)}
  end

  def gen_sig(%__MODULE__{} = event, privkey) do
    {:ok, sig} = Secp256k1.sign(event.id, privkey)
    sig
  end

  def load_sig(%__MODULE__{} = event, privkey) do
    %__MODULE__{event | sig: gen_sig(event, privkey)}
  end

  def valid?(%__MODULE__{} = event) do
    sig = Secp256k1.verify(event.sig, event.id, event.pubkey)

    sig == :valid and gen_id(event) == event.id
  end

  def create(content, seckey, kind) do
    {:ok, pubkey} = Secp256k1.pubkey(seckey)

    %__MODULE__{
      pubkey: pubkey,
      created_at: DateTime.utc_now(),
      kind: kind,
      content: content
    }
    |> load_id()
    |> load_sig(seckey)
  end

  def serialize_kind(:set_metadata), do: 0
  def serialize_kind(:text_note), do: 1
  def serialize_kind(:recommend_server), do: 2

  def set_metadata(metadata, privkey), do: create(metadata, privkey, :set_metadata)
  def text_note(note, privkey), do: create(note, privkey, :text_note)
  def recommend_server(url, privkey), do: create(url, privkey, :recommend_server)
end

defimpl Jason.Encoder, for: Nostr.Event do
  def encode(%Nostr.Event{} = event, opts) do
    %{
      id: event.id,
      pubkey: Base.encode16(event.pubkey),
      created_at: DateTime.to_unix(event.created_at),
      kind: Nostr.Event.serialize_kind(event.kind),
      tags: event.tags,
      content: event.content,
      sig: Base.encode16(event.sig)
    }
    |> Jason.Encode.map(opts)
  end
end
