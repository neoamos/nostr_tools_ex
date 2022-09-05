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

  def gen_id(%__MODULE__{} = event) do
    {:ok, encoded} =
      Jason.encode([
        0,
        event.pubkey,
        DateTime.to_unix(event.created_at),
        event.kind,
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
    {:ok, sig} =
      Secp256k1.Schnorr.sign(
        Base.decode16!(event.id, case: :lower),
        privkey
      )

    Base.encode16(sig, case: :lower)
  end

  def load_sig(%__MODULE__{} = event, privkey) do
    %__MODULE__{event | sig: gen_sig(event, privkey)}
  end

  def valid?(%__MODULE__{} = event) do
    sig =
      Secp256k1.Schnorr.verify(
        Base.decode16!(event.sig, case: :lower),
        Base.decode16!(event.id, case: :lower),
        Base.decode16!(event.pubkey, case: :lower)
      )

    sig == :valid and gen_id(event) == event.id
  end

  def create(content, privkey, kind) do
    {:ok, pubkey} = Secp256k1.Schnorr.xonly_pubkey(privkey)

    %__MODULE__{
      pubkey: Base.encode16(pubkey, case: :lower),
      created_at: DateTime.utc_now(),
      kind: kind,
      content: content
    }
    |> load_id()
    |> load_sig(privkey)
  end

  def set_metadata(metadata, privkey), do: create(metadata, privkey, :set_metadata)
  def text_note(note, privkey), do: create(note, privkey, :text_note)
  def recommend_server(url, privkey), do: create(url, privkey, :recommend_server)
end

defimpl Jason.Encoder, for: Nostr.Event do
  def encode(%Nostr.Event{} = event, opts) do
    %{
      id: event.id,
      pubkey: event.pubkey,
      created_at: DateTime.to_unix(event.created_at),
      kind: serialize_kind(event.kind),
      tags: event.tags,
      content: event.content,
      sig: event.sig
    }
    |> Jason.Encode.map(opts)
  end

  defp serialize_kind(:set_metadata), do: 0
  defp serialize_kind(:text_note), do: 1
  defp serialize_kind(:recommend_server), do: 2
end
