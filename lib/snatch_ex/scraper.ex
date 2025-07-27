defmodule SnatchEx.Scraper do
  def extract_results(html, selector, base_url) do
    html
    |> Floki.parse_document!()
    |> Floki.find(selector)
    |> Floki.attribute("href")
    |> Enum.map(&(base_url |> URI.merge(&1) |> URI.to_string()))
    |> then(&{:ok, &1})
  end

  def extract_content(selector, html) do
    html
    |> Floki.parse_document!()
    |> Floki.find(selector)
    |> Floki.text()
    |> then(&{:ok, %{content: &1}})
  end
end
