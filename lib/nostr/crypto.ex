defmodule NostrTools.Crypto do
  @moduledoc """
  Defines cryptographic functions relevant to Nostr
  """

  @doc "Calculates the sha256 of a binary"
  @doc since: "1.0.0"
  def sha256(data) do
    :crypto.hash(:sha256, data)
  end

  @doc "Generates a schnorr signature of the data using the given private key"
  @doc since: "1.0.0"
  def sign(data, seckey) do
    Secp256k1.schnorr_sign(data, seckey)
  end

  @doc "Verifies the schnor signature on the data with the given pubkey"
  @doc since: "1.0.0"
  def verify(sig, data, pubkey) do
    Secp256k1.schnorr_valid?(sig, data, pubkey)
  end

  @doc "Returns the xonly pubkey of the given private key"
  @doc since: "1.0.0"
  def pubkey(seckey) do
    Secp256k1.pubkey(seckey, :xonly)
  end

  @doc "Securely generates a randome private key"
  @doc since: "1.0.0"
  def generate_seckey() do
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

  @doc """
  Validates that the given string is a valid lower case hex encoding and the returned binary is a specified length
  """
  @doc since: "1.0.0"
  def valid_hex?(hex, length) when is_binary(hex) do
    case Base.decode16(hex, case: :lower) do
      {:ok, bin} -> byte_size(bin) == length
      _ -> false
    end
  end
  def valid_hex?(hex, _) when not is_binary(hex), do: false
end
