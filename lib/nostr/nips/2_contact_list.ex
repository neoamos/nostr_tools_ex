defmodule NostrTools.Nips.ContactList do
  @moduledoc """
  A collection of functions useful for parsing contact list events
  """
  @moduledoc since: "0.1.0"
  alias NostrTools.Event
  alias NostrTools.Crypto

  def get_contact_list %Event{} = event do
    event.tags
      |> Enum.filter(fn tag ->
        (length(tag) >= 2) and Enum.at(tag, 0) == "p" and Crypto.valid_hex?(Enum.at(tag, 1), 32)
      end)
      |> Enum.map(fn tag ->
        %{
          pubkey: Enum.at(tag, 1),
          relay: Enum.at(tag, 2),
          petname: Enum.at(tag, 3)
        }
      end)
  end
end
