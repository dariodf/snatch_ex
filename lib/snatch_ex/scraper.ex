defmodule SnatchEx.Scraper do
  def extract_results(html, selector, base_url) do
    html
    |> Floki.parse_document!()
    |> Floki.find(selector)
    |> Floki.attribute("href")
    |> Enum.map(&(base_url |> URI.merge(&1) |> URI.to_string()))
    |> then(&{:ok, &1})
  end

  def extract_contents(html, selectors) do
    Enum.map(selectors, fn {key, selector} ->
      value =
        html
        |> Floki.parse_document!()
        |> Floki.find(selector)
        |> Floki.text()
        |> then(&Regex.replace(~r/^\s+|\s+$/, &1, ""))

      {key, value}
    end)
    |> Enum.into(%{})
    |> then(&{:ok, &1})
  end
end
