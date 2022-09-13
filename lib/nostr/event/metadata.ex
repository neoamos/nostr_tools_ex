defmodule Nostr.Event.Metadata do
  @moduledoc false

  defstruct [:name, :about, :picture]

  @type t() :: %__MODULE__{
          name: String.t() | nil,
          about: String.t() | nil,
          picture: String.t() | nil
        }
end

defimpl Jason.Encoder, for: Nostr.Event.Metadata do
  alias Nostr.Event.Metadata

  def encode(%Metadata{} = metadata, opts) do
    %{}
    |> maybe_put_name(metadata)
    |> maybe_put_about(metadata)
    |> maybe_put_picture(metadata)
    |> Jason.Encode.map(opts)
  end

  defp maybe_put_name(result, %Metadata{name: nil}), do: result
  defp maybe_put_name(result, %Metadata{name: username}), do: Map.put(result, :name, username)

  defp maybe_put_about(result, %Metadata{about: nil}), do: result
  defp maybe_put_about(result, %Metadata{about: about}), do: Map.put(result, :about, about)

  defp maybe_put_picture(result, %Metadata{picture: nil}), do: result

  defp maybe_put_picture(result, %Metadata{picture: picture}),
    do: Map.put(result, :picture, picture)
end
