defmodule NostrTools.Event do
  @moduledoc false

  alias NostrTools.Crypto

  @enforce_keys [:pubkey, :created_at, :kind, :content]
  defstruct id: :not_loaded,
            pubkey: nil,
            created_at: nil,
            kind: nil,
            tags: [],
            content: nil,
            sig: :not_loaded

  @type kind() :: 
    :set_metadata | 
    :text_note | 
    :recommend_relay |
    :contact_list |
    :encrypted_dm |
    :event_deletion |
    :reaction |
    :metadata |
    :other
  @type id() :: <<_::32, _::_*8>>
  @type content() :: String.t()
  @type tags() :: [[String.t()]]
  @type t() :: %__MODULE__{
          id: id() | :not_loaded,
          pubkey: Secp256k1.xonly_pubkey(),
          created_at: DateTime.t(),
          kind: non_neg_integer(),
          tags: tags(),
          content: content(),
          sig: Secp256k1.schnorr_sig() | :not_loaded
        }

  @spec gen_id(event :: t()) :: id()
  def gen_id(%__MODULE__{} = event) do
    {:ok, encoded} =
      Jason.encode([
        0,
        Base.encode16(event.pubkey, case: :lower),
        DateTime.to_unix(event.created_at),
        event.kind,
        event.tags,
        event.content
      ])

    Crypto.sha256(encoded)
  end

  @spec load_id(event :: t()) :: t()
  def load_id(%__MODULE__{} = event) do
    %__MODULE__{event | id: gen_id(event)}
  end

  @spec gen_sig(event :: t(), seckey :: Secp256k1.seckey()) :: Secp256k1.schnorr_sig()
  def gen_sig(%__MODULE__{} = event, seckey) do
    Crypto.sign(event.id, seckey)
  end

  @spec load_sig(event :: t(), seckey :: Secp256k1.seckey()) :: t()
  def load_sig(%__MODULE__{} = event, seckey) do
    %__MODULE__{event | sig: gen_sig(event, seckey)}
  end

  @spec valid?(event :: t()) :: boolean()
  def valid?(%__MODULE__{} = event) do
    valid_sig?(event) and valid_id?(event)
  end

  @spec valid_sig?(event :: t()) :: boolean()
  def valid_sig?(%__MODULE__{} = event) do
    Crypto.verify(event.sig, event.id, event.pubkey)
  end

  @spec valid_id?(event :: t()) :: boolean()
  def valid_id?(%__MODULE__{} = event) do
    gen_id(event) == event.id
  end

  @spec create(content :: content(), seckey :: Secp256k1.seckey(), 
  kind :: non_neg_integer(), tags :: tags()) :: {:ok, t()} | {:error, term()}
  def create(content, seckey, kind, tags \\ []) do
    if valid_tags?(tags) do
      event = %__MODULE__{
        pubkey: Crypto.pubkey(seckey),
        created_at: (DateTime.utc_now() |> DateTime.truncate(:second)),
        kind: kind,
        content: content,
        tags: tags
      }
      |> load_id()
      |> load_sig(seckey)
      {:ok, event}
    else
      {:error, "Invalid tags"}
    end
  end

  @spec create(params :: map()) :: {:ok, t()} | term()
  def create params do
    with  :ok <- validate_params(params),
          {:ok, id} <- Base.decode16(params["id"], case: :mixed),
          {:ok, pubkey} <- Base.decode16(params["pubkey"], case: :mixed),
          {:ok, sig} <- Base.decode16(params["sig"], case: :mixed),
          {:ok, created_at} <- DateTime.from_unix(params["created_at"])
    do
      {:ok,
        %__MODULE__{
          id: id,
          pubkey: pubkey,
          created_at: created_at,
          kind: params["kind"],
          tags: params["tags"],
          content: params["content"],
          sig: sig
        }
      }
    else
      other -> other
    end
  end

  @spec kind_name(kind :: non_neg_integer()) :: kind()
  def kind_name(0), do: :set_metadata
  def kind_name(1), do: :text_note
  def kind_name(2), do: :recommend_relay
  def kind_name(3), do: :contact_list
  def kind_name(4), do: :encrypted_dm
  def kind_name(5), do: :event_deletion
  def kind_name(7), do: :reaction
  def kind_name(_), do: :other

  @spec kind_number(kind :: kind()) :: non_neg_integer()
  def kind_number(:set_metadata), do: 0
  def kind_number(:text_note), do: 1
  def kind_number(:recommend_relay), do: 2
  def kind_number(:contact_list), do: 3
  def kind_number(:encrypted_dm), do: 4
  def kind_number(:event_deletion), do: 5
  def kind_number(:reaction), do: 6
  def kind_number(:metadata), do: 7

  @spec validate_params(params :: map()) :: :ok | {:error, String.t()}
  def validate_params params do
    cond do
      !params["id"] or !Crypto.valid_hex?(params["id"], 32) -> 
        {:error, "Invalid id"}
      !params["pubkey"] or !Crypto.valid_hex?(params["pubkey"], 32) ->
        {:error, "Invalid pubkey"}
      !params["sig"] or !Crypto.valid_hex?(params["sig"], 64) ->
        {:error, "Invalid sig"}
      !params["created_at"] or !is_number(params["created_at"]) or params["created_at"] < 0 ->
        {:error, "Invalid created_at"}
      !params["kind"] or !is_number(params["kind"]) or params["kind"] < 0 ->
        {:error, "Invalid kind"}
      !params["tags"] or !valid_tags?(params["tags"]) ->
        {:error, "Invalid tags"}
      !params["content"] or !is_binary(params["content"]) -> 
        {:error, "Invalid content"}
      true -> :ok
    end
  end

  def valid_tags? tags do
    is_list(tags) and Enum.all?(tags, fn t -> 
      is_list(t) and Enum.all?(t, fn v ->
        is_binary(v)
      end)
    end)
  end

end

defimpl Jason.Encoder, for: NostrTools.Event do
  def encode(%NostrTools.Event{} = event, opts) do
    %{
      id: Base.encode16(event.id, case: :lower),
      pubkey: Base.encode16(event.pubkey, case: :lower),
      created_at: DateTime.to_unix(event.created_at),
      kind: event.kind,
      tags: event.tags,
      content: event.content,
      sig: Base.encode16(event.sig, case: :lower)
    }
    |> Jason.Encode.map(opts)
  end
end
