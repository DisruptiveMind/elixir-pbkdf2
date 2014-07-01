defmodule KeyGeneratorTest do
  use ExUnit.Case, async: true

  import KeyGenerator
  use Bitwise

  @max_length bsl(1, 32) - 1

  test "returns an :error tuple when the length is too large" do
    error = {:error, :derived_key_too_long}
    assert generate("secret", "salt", length: @max_length + 1) == error
  end

  test "it works" do
    key = generate("password", "salt", iterations: 1, length: 20)
    assert byte_size(key) == 20
    assert to_hex(key) == "0c60c80f961f0e71f3a9b524af6012062fe037a6"

    key = generate("password", "salt", iterations: 2, length: 20)
    assert byte_size(key) == 20
    assert to_hex(key) == "ea6c014dc72d6f8ccd1ed92ace1d41f0d8de8957"

    key = generate("password", "salt", iterations: 4096, length: 20)
    assert byte_size(key) == 20
    assert to_hex(key) == "4b007901b765489abead49d926f721d065a429c1"

    key = generate("passwordPASSWORDpassword", "saltSALTsaltSALTsaltSALTsaltSALTsalt", iterations: 4096, length: 25)
    assert byte_size(key) == 25
    assert to_hex(key) == "3d2eec4fe41c849b80c8d83662c0e44a8b291a964cf2f07038"

    key = generate("pass\0word", "sa\0lt", iterations: 4096, length: 16)
    assert byte_size(key) == 16
    assert to_hex(key) == "56fa6aa75548099dcc37d7f03425e0c3"

    key = generate("password", "salt")
    assert byte_size(key) == 64
    assert to_hex(key) == "04231d47c2eb88506945b26b2325e6adfeeba088cbad968b56006784539d5214ce970d912ec2049b6e88be8bad7eae9d9e10aa061224034fed48d03f95ff9587"
  end

  test ":sha256" do
    key = generate("password", "salt", digest: :sha256)
    assert byte_size(key) == 64
    assert to_hex(key) == "88b3b1131f741bcbeb02541c8c2e97bd8bed62ab6425542e45512b7312f440eb632c2812e46d4604102ba7618e9d6d7d2f8128f6266b4a03264d2a0460b7dcb3"
  end
end
