defmodule Nostr.Event do
  @moduledoc false

  alias Nostr.Crypto
  alias Nostr.Event.Metadata

  @enforce_keys [:pubkey, :created_at, :kind, :content]
  defstruct id: :not_loaded,
            pubkey: nil,
            created_at: nil,
            kind: nil,
            tags: [],
            content: nil,
            sig: :not_loaded

  @type kind() :: :set_metadata | :text_note | :recommend_server
  @type id() :: <<_::32, _::_*8>>
  @type content() :: String.t() | Metadata.t()
  @type t() :: %__MODULE__{
          id: id() | :not_loaded,
          pubkey: Secp256k1.pubkey(),
          created_at: DateTime.t(),
          kind: kind(),
          tags: [Nostr.Tag.t()],
          content: content(),
          sig: Secp256k1.signature() | :not_loaded
        }

  @spec gen_id(event :: t()) :: id()
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

    Crypto.sha256(encoded)
  end

  @spec load_id(event :: t()) :: t()
  def load_id(%__MODULE__{} = event) do
    %__MODULE__{event | id: gen_id(event)}
  end

  @spec gen_sig(event :: t(), seckey :: Secp256k1.seckey()) :: Secp256k1.signature()
  def gen_sig(%__MODULE__{} = event, seckey) do
    Crypto.sign(event.id, seckey)
  end

  @spec load_sig(event :: t(), seckey :: Secp256k1.seckey()) :: t()
  def load_sig(%__MODULE__{} = event, seckey) do
    %__MODULE__{event | sig: gen_sig(event, seckey)}
  end

  @spec valid?(event :: t()) :: boolean()
  def valid?(%__MODULE__{} = event) do
    Crypto.verify(event.sig, event.id, event.pubkey) == :valid and gen_id(event) == event.id
  end

  @spec create(content :: content(), seckey :: Secp256k1.seckey(), kind :: kind()) :: t()
  def create(content, seckey, kind) do
    %__MODULE__{
      pubkey: Crypto.pubkey(seckey),
      created_at: DateTime.utc_now(),
      kind: kind,
      content: content
    }
    |> load_id()
    |> load_sig(seckey)
  end

  @spec serialize_kind(kind :: kind()) :: non_neg_integer()
  def serialize_kind(:set_metadata), do: 0
  def serialize_kind(:text_note), do: 1
  def serialize_kind(:recommend_server), do: 2

  @spec deserialize_kind(kind :: non_neg_integer()) :: kind()
  def deserialize_kind(0), do: :set_metadata
  def deserialize_kind(1), do: :text_note
  def deserialize_kind(2), do: :recommend_server

  @spec set_metadata(metadata :: Metadata.t(), seckey :: Secp256k1.seckey()) :: t()
  def set_metadata(metadata, seckey), do: create(metadata, seckey, :set_metadata)

  @spec text_note(note :: String.t(), seckey :: Secp256k1.seckey()) :: t()
  def text_note(note, seckey), do: create(note, seckey, :text_note)

  @spec recommend_server(url :: String.t(), seckey :: Secp256k1.seckey()) :: t()
  def recommend_server(url, seckey), do: create(url, seckey, :recommend_server)

  def validate_json_event json do
    %{
      "type" => "object",
      "required" => ["id", "pubkey", "sig", "created_at", "kind", "tags", "content"],
      "properties" => %{
        "id" => %{"type" => "string"},
        "pubkey" => %{"type" => "string"},
        "sig" => %{"type" => "string"},
        "created_at" => %{"type" => "integer"},
        "kind" => %{"type" => "integer"},
        "tags" => %{"type" => "array"},
        "content" => %{"type" => "string"}
      }
    }
    |> ExJsonSchema.Schema.resolve()
    |> ExJsonSchema.Validator.validate(json)
  end

  def decode(input) do
    with {:ok, event} <- Jason.decode(input),
          :ok <- validate_json_event(event),
          {:ok, id} <- Base.decode16(event["id"], case: :mixed),
          {:ok, pubkey} <- Base.decode16(event["pubkey"], case: :mixed),
          {:ok, sig} <- Base.decode16(event["sig"], case: :mixed),
          {:ok, created_at} <- DateTime.from_unix(event["created_at"])
    do
      {:ok,
        %__MODULE__{
          id: id,
          pubkey: pubkey,
          created_at: created_at,
          kind: deserialize_kind(event["kind"]),
          tags: event["tags"],
          content: event["content"],
          sig: sig
        }
      }
    else
      other -> other
    end
  end
end

defimpl Jason.Encoder, for: Nostr.Event do
  def encode(%Nostr.Event{} = event, opts) do
    %{
      id: Base.encode16(event.id, case: :lower),
      pubkey: Base.encode16(event.pubkey, case: :lower),
      created_at: DateTime.to_unix(event.created_at),
      kind: Nostr.Event.serialize_kind(event.kind),
      tags: event.tags,
      content: event.content,
      sig: Base.encode16(event.sig, case: :lower)
    }
    |> Jason.Encode.map(opts)
  end
end
