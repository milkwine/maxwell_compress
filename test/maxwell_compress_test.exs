defmodule MaxwellCompressTest do
  use ExUnit.Case

  alias Maxwell.Conn

  defmodule HttpBinClient do
    use Maxwell.Builder
    middleware Maxwell.Middleware.BaseUrl, "http://httpbin.org"
    middleware Maxwell.Middleware.Json
    middleware Maxwell.Middleware.Compress
    adapter Maxwell.Adapter.Httpc
  end

  test "normal gzip response" do

    conn = "/gzip"
      |> Conn.new
      |> HttpBinClient.get!

    assert Conn.get_req_headers(conn)["accept-encoding"] == "gzip"

    assert Conn.get_resp_body(conn)["gzipped"] == true
  end

  defmodule ModuleAdapter do
    def call(conn) do
      conn = %{conn|state: :sent}
      case conn.path do
        "/no_encode" ->
           %{conn| status: 200, resp_body: "raw msg"}
        "/not_support" ->
           %{conn| status: 200, resp_headers: %{"content-encoding" => "Foo"},
             resp_body: "raw msg"}
        "/decode_error" ->
           %{conn| status: 200, resp_headers: %{"content-encoding" => "gzip"},
             resp_body: "not a gzip fmt msg"}
      end
    end
  end

  defmodule Client do
    use Maxwell.Builder
    middleware Maxwell.Middleware.Compress
    adapter ModuleAdapter
  end

  test "content_encoding not exists should return raw response" do
    assert "/no_encode"
      |> Conn.new
      |> Client.get!
      |> Conn.get_resp_body  == "raw msg"
  end

  test "content_encoding not support should return raw response" do
    assert "/not_support"
      |> Conn.new
      |> Client.get!
      |> Conn.get_resp_body  == "raw msg"
  end

  test "decode error should return error" do
    {:error, error, _conn} = "/decode_error"
      |> Conn.new
      |> Client.get

    assert error == {:decode_error, %ErlangError{original: :data_error}}
  end
end
