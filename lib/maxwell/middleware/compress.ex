defmodule Maxwell.Middleware.Compress do
  use Maxwell.Middleware
  alias Maxwell.Conn

  @support_encoding ["gzip"]

  def init(opts), do: opts[:type] || Enum.join(@support_encoding, ", ")

  def request(%Maxwell.Conn{} = conn, type), do: conn |> Conn.put_req_header("accept-encoding", type)

  def response(%Maxwell.Conn{} = conn, _type) do
    with {:ok, content_encoding} <- fetch_resp_content_encoding(conn),
         true <- valid_encoding?(content_encoding, conn.resp_body),
         {:ok, resp_body} <- decode(content_encoding, conn.resp_body) do
      %{conn | resp_body: resp_body}
    else
      :error -> conn
      false -> conn
      {:error, reason} -> {:error, {:decode_error, reason}, conn}
    end
  end

  defp valid_encoding?(content_encoding, body), do: present?(body) && content_encoding in @support_encoding

  defp fetch_resp_content_encoding(conn) do
    if content_encoding = Conn.get_resp_header(conn, "content-encoding") do
      {:ok, content_encoding}
    else
      :error
    end
  end

  defp present?(""), do: false
  defp present?([]), do: false
  defp present?(term) when is_binary(term) or is_list(term), do: true
  defp present?(_), do: false

  defp decode("gzip", body) do
    try do
      resp = :zlib.gunzip(body)
      {:ok, resp}
    rescue
      e in ErlangError -> {:error, e}
    end
  end
end
