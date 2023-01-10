defmodule NostrTools.Message do
  @moduledoc """
  Defines functions for enerating protocol messages.
  """

  alias NostrTools.Event

  defstruct type: nil

  def event(%Event{} = event) do
    ["EVENT", event]
  end

  def event(sub_id, %Event{} = event) do
    ["EVENT", sub_id, event]
  end

  def req(sub_id, filters) do
    ["REQ", sub_id, filters]
  end

  def close(sub_id) do
    ["CLOSE", sub_id]
  end

  def notice(message) do
    ["NOTICE", message]
  end
end
