# NostrTools for Elixir

NostrTools implements the core Nostr protocol primitives and other useful functions needed to develop a variety of different Nostr applications in Elixir.

There is a lot of NIPs functionality that still needs to be implemented

# Examples

## Generate keys
```
iex> seckey = NostrTools.Crypto.generate_seckey()
iex> pubkey = NostrTools.Crypto.pubkey(seckey)
```

## Create a new Event
```
iex> seckey = NostrTools.Crypto.generate_seckey()
iex> event = NostrTools.Event.create("content", seckey, 1, [])
```

## Encode and decode an event to json
```
iex> seckey = NostrTools.Crypto.generate_seckey()
iex> {:ok, event} = NostrTools.Event.create("content", seckey, 1, [])
iex> {:ok, json_event} = Jason.encode(event)
iex> {:ok, decoded_event} = NostrTools.Event.create(Jason.decode!(json_event))
iex> event == decoded_event
true
```

## Verify an event

```
iex> seckey = NostrTools.Crypto.generate_seckey()
iex> {:ok, event} = NostrTools.Event.create("content", seckey, 1, [])
iex> NostrTools.Event.valid?(event)
true

iex> NostrTools.Event.valid?(%NostrTools.Event{event | content: "wrong content"})
false
```

## Generate a request for events

```
iex> filter = %NostrTools.Filter{since: 1673380970}
iex> Jason.encode!(NostrTools.Message.req("sub id", filter))
"[\"REQ\",\"sub id\",{\"since\":1673380970}]"
```