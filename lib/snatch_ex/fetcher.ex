defmodule SnatchEx.Fetcher do
  @finch_name SnatchEx.Finch

  def search(url_template, query) do
    url = String.replace(url_template, "{query}", URI.encode(query))
    case Finch.build(:get, url) |> Finch.request(@finch_name) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      error -> error
    end
  end

  def fetch_page(url) do
    case Finch.build(:get, url) |> Finch.request(@finch_name) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      error -> error
    end
  end
end
