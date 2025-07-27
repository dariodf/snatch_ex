defmodule SnatchEx do
  @moduledoc false

  alias SnatchEx.{Fetcher, Scraper, Renderer}

  def snatch(search_text) do
    config = config()

    Enum.find_value(config["search"], fn search_config ->
      with base_url <- URI.to_string(%{URI.parse(search_config["url"]) | path: nil, query: nil}),
           {:ok, html} <- Fetcher.search(search_config["url"], search_text),
           {:ok, target_url} <- extract_first_result(html, base_url, search_config["selectors"]),
           {:ok, target_html} <- Fetcher.fetch_page(target_url |> IO.inspect()),
           {:ok, data} <- Scraper.extract_contents(target_url, target_html, config["scraping"]),
           {:ok, pdf_binary} <- Renderer.to_pdf(config["rendering"]["template"], data) do
        {:ok, pdf_binary}
      else
        _ -> nil
      end
    end) || {:error, :no_results}
  end

  defp extract_first_result(html, base_url, [scrape_config | []]) do
    %{"selector" => selector, "attribute" => attribute} = scrape_config

    with {:ok, [target_url | _]} <- Scraper.extract_results(html, selector, attribute, base_url) do
      {:ok, target_url}
    end
  end

  defp extract_first_result(html, base_url, [scrape_config | tail]) do
    %{"selector" => selector, "attribute" => attribute} = scrape_config

    with {:ok, [target_url | _]} <- Scraper.extract_results(html, selector, attribute, base_url),
         {:ok, html} <- Fetcher.fetch_page(target_url) do
      extract_first_result(html, base_url, tail)
    end
  end

  defp config do
    yaml = """
    search:
      "https://gametabs.net/tabs?search={query}":
        - selector: "div.results-list > a"
          attribute: "href"

    scraping:
      "https://gametabs.net":
        content: "pre"
        name: "#tab-page-tab-name"
        band: "#tab-page-game-name"

    rendering:
      template: |
        {name} - {band}

        <pre style="font-size:10px;">
        {content}
        </pre>
    """

    {:ok, parsed} = YamlElixir.read_from_string(yaml)

    parsed
  end
end
