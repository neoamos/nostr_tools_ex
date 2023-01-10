defmodule NostrTest do
  use ExUnit.Case

  doctest Nostr

  alias Nostr.Crypto
  alias Nostr.Event
  alias Nostr.Filter
  alias Nostr.Message

  setup_all do
    {seckey, pubkey} = Secp256k1.keypair(:compressed)
    {:ok,
      %{
        seckey: seckey,
        pubkey: pubkey,
        event1: ~s<{\"id\":\"a644a05ea8bf9411ef62aa216a1dce2b19e12c6447e3d9f797cfb68f658f3e5c\",\"pubkey\":\"591815bdd794d8a25e629a335e021301bf447162ad7145893733404a52feaae8\",\"created_at\":1672704408,\"kind\":3,\"tags\":[[\"p\",\"645681b9d067b1a362c4bee8ddff987d2466d49905c26cb8fec5e6fb73af5c84\"],[\"p\",\"64a159154f7bdf68116c59463cef4fda68f7270c656832e0587014af2fe96949\"],[\"p\",\"24e37c1e5b0c8ba8dde2754bcffc63b5b299f8064f8fb928bcf315b9c4965f3b\"],[\"p\",\"33868b6613a1d5ea52c3a7cb75e860e635252331688f206bab41f51f3a6ef08e\"],[\"p\",\"a6faaebe9051a62a19ba608b93d1105b1e982a31512415290f605140f14f49f4\"],[\"p\",\"a8e76c3ace7829f9ee44cf9293309e21a1824bf1e57631d00685a1ed0b0bd8a2\"],[\"p\",\"00000000ed8248be0eeb6e2616e64a6ad9796f9bbd15fafd3ec9e239cf3041a2\"],[\"p\",\"fcf70a45cfa817eaa813b9ba8a375d713d3169f4a27f3dcac3d49112df67d37e\"],[\"p\",\"00000000827ffaa94bfea288c3dfce4422c794fbb96625b6b31e9049f729d700\"],[\"p\",\"3efdaebb1d8923ebd99c9e7ace3b4194ab45512e2be79c1b7d68d9243e0d2681\"],[\"p\",\"82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2\"],[\"p\",\"f9acb0b034c4c1177e985f14639f317ef0fedee7657c060b146ee790024317ec\"],[\"p\",\"5e7ae588d7d11eac4c25906e6da807e68c6498f49a38e4692be5a089616ceb18\"],[\"p\",\"57621dc320ccea1880b0e027eddecb530b010c16571e173e7905c38404967f8c\"]],\"content\":\"\",\"sig\":\"3e7ebe0b438250252365fb15a5851ff2dec36e2d5896c416a8efb35d1d1b3eff0f49c4cc17b2ea9701deb2ddf8caaac342d0992e91a0fbf42a8a2f0944f58048\"}>
      }
    }
  end

  test "event validation", %{seckey: s, pubkey: p} do
    {:ok, event} = Event.create("asdf", s, 1, [["t", "test"]])
    
    assert Event.valid?(event)
    refute Event.valid?(%Event{event | content: "fdsa"})
    refute Event.valid?(%Event{event | kind: 2})
    refute Event.valid?(%Event{event | tags: [["t", "fail"]]})
    refute Event.valid?(%Event{event | created_at: DateTime.from_unix!(1672699556)})
  end

  test "event serialization", %{seckey: s, pubkey: p, event1: event1_json} do
    {:ok, event} = Event.create("asdf", s, 1, [["t", "test"]])
    json = Jason.encode!(event)
    {:ok, decoded_event} = Event.create(Jason.decode!(json))
    assert event == decoded_event
    assert Event.valid?(decoded_event)
  end

  test "event parsing", %{event1: event_json} do
    {:ok, event} = Event.create(Jason.decode!(event_json))

    assert Event.valid_id?(event)
    assert Event.valid?(event)
  end
end
