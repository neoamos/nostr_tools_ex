defmodule Secp256k1 do
  @moduledoc false

  # d3c43932b27b0f852349f32afaff1010fa08a1fe2172372d01e8d8ad21e756c2

  def test do
    priv_key =
      Base.decode16!("f5e5f52c644bc8e2726a4457e7b975fc61c31e8dd56b1619ef67802f22b00042",
        case: :lower
      )

    {:ok, pub_key} = Secp256k1.Schnorr.xonly_pubkey(priv_key)

    IO.puts("Privkey: #{Base.encode16(priv_key, case: :lower)}")
    IO.puts("Pubkey: #{Base.encode16(pub_key, case: :lower)}")

    message = "hello"
    msg_hash = :crypto.hash(:sha256, message)
    {:ok, signature} = Secp256k1.Schnorr.sign(msg_hash, priv_key)

    IO.puts("Message: #{Base.encode16(msg_hash, case: :lower)}")
    IO.puts("Signature: #{Base.encode16(signature, case: :lower)}")

    Secp256k1.Schnorr.verify(signature, msg_hash, pub_key)
  end

  def test2 do
    pub_key = "ccd1f6ee3250dcd71d7c55181ffa70a9bc07d6cd90541875e3142ab642dab351"
    message = "004e083bd64be0933ac7fda30929564c3a78ee8fbd2b15ca3e0c41503ea7cf79"

    sig =
      "89d49ad024e0365c9490690da4e8e1ad403c44ce3585d08e73421773392e9a632b0589ead8c11f1408e47d2f6e1822338548705d15de362d4b29710f80de2ec6"

    Secp256k1.Schnorr.verify(
      Base.decode16!(sig, case: :lower),
      Base.decode16!(message, case: :lower),
      Base.decode16!(pub_key, case: :lower)
    )
  end
end
