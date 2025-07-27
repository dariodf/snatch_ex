defmodule SnatchEx.Scraper do
  def extract_results(html, selector, attribute, base_url) do
    html
    |> Floki.parse_document!()
    |> Floki.find(selector)
    |> Floki.attribute(attribute)
    |> Enum.map(&(base_url |> URI.merge(&1) |> URI.to_string()))
    |> then(&{:ok, &1})
  end

  def extract_contents(url, html, scraping_configs) do
    url_host = URI.parse(url).host

    selectors =
      Enum.find_value(scraping_configs, [], fn {config_url, selectors} ->
        if url_host == URI.parse(config_url).host, do: selectors
      end)

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
