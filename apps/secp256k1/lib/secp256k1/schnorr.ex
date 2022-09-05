defmodule Secp256k1.Schnorr do
  @moduledoc false

  @on_load :load_nifs

  def load_nifs do
    :secp256k1
    |> Application.app_dir("priv/schnorr")
    |> :erlang.load_nif(0)
  end

  def xonly_pubkey(_priv_key) do
    raise "Not implemented"
  end

  def sign(_message, _priv_key) do
    raise "Not implemented"
  end

  def verify(_signature, _message, _pub_key) do
    raise "Not implemented"
  end
end
