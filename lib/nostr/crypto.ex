defmodule Nostr.Crypto do
  @moduledoc false

  def sha256(data) do
    :crypto.hash(:sha256, data)
  end

  def sign(data, seckey) do
    Secp256k1.sign(data, seckey)
  end

  def verify(sig, data, pubkey) do
    Secp256k1.verify(sig, data, pubkey)
  end

  def pubkey(seckey) do
    Secp256k1.pubkey(seckey, :xonly)
  end

  def encrypt(message, shared_secret) do
    iv = :crypto.strong_rand_bytes(16)
    {encrypt(message, shared_secret, iv), iv}
  end

  def encrypt(message, shared_secret, iv) do
    :crypto.crypto_one_time(:aes_256_cbc, shared_secret, iv, message,
      encrypt: true,
      padding: :pkcs_padding
    )
  end

  def decrypt(message, shared_secret, iv) do
    :crypto.crypto_one_time(:aes_256_cbc, shared_secret, iv, message,
      encrypt: false,
      padding: :pkcs_padding
    )
  end
end
