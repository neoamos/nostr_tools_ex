defmodule NostrTools.Crypto do
  @moduledoc false

  def sha256(data) do
    :crypto.hash(:sha256, data)
  end

  def sign(data, seckey) do
    Secp256k1.schnorr_sign(data, seckey)
  end

  def verify(sig, data, pubkey) do
    Secp256k1.schnorr_valid?(sig, data, pubkey)
  end

  def pubkey(seckey) do
    Secp256k1.pubkey(seckey, :xonly)
  end

  def seckey() do
    {seckey, _pubkey} = Secp256k1.keypair(:xonly)
    seckey
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

  def valid_hex?(hex, length) when is_binary(hex) do
    case Base.decode16(hex, case: :lower) do
      {:ok, bin} -> byte_size(bin) == length
      _ -> false
    end
  end
  def valid_hex?(hex, _) when not is_binary(hex), do: false
end
