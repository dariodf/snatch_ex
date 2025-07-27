defmodule SnatchEx.Scraper do
  def extract_results(html, selector, attribute, base_url) do
    html
    |> Floki.parse_document!()
    |> Floki.find(selector)
    |> Floki.attribute(attribute)
    |> Enum.map(fn url ->
      url
      |> remove_leading_and_trailing_whitespaces()
      |> then(&(base_url |> URI.merge(&1) |> URI.to_string()))
    end)
    |> case do
      [] -> {:error, :no_results}
      results -> {:ok, results}
    end
  end

  def extract_contents(url, html, scraping_configs) do
    url_host = URI.parse(url).host

    selectors =
      Enum.find_value(scraping_configs, [], fn {config_url, selectors} ->
        if url_host == URI.parse(config_url).host, do: selectors
      end)

    if selectors do
      Enum.map(selectors, fn {key, selector} ->
        value =
          html
          |> Floki.parse_document!()
          |> Floki.find(selector)
          |> Floki.text()
          |> remove_leading_and_trailing_whitespaces()

        {key, value}
      end)
      |> Enum.into(%{})
      |> case do
        %{"content" => content} when is_nil(content) or content == "" -> {:error, :parsing_error}
        data -> {:ok, data}
      end
    end
  end

  defp remove_leading_and_trailing_whitespaces(string) do
    Regex.replace(~r/^\s+|\s+$/, string, "")
  end
end
