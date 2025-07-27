defmodule SnatchEx do
  @moduledoc false

  alias SnatchEx.{Fetcher, Scraper, Renderer}

  def snatch(search_text) do
    config = config()

    Enum.find_value(config["search"], fn {search_url, results_selectors} ->
      with [%{"selector" => selector, "attribute" => attribute} | _] = results_selectors,
           {:ok, html} <- Fetcher.search(search_url, search_text),
           base_url <- URI.to_string(%{URI.parse(search_url) | query: nil}),
           {:ok, [target_url | _]} <-
             Scraper.extract_results(html, selector, attribute, base_url),
           {:ok, target_html} <- Fetcher.fetch_page(target_url),
           {:ok, data} <- Scraper.extract_contents(target_url, target_html, config["scraping"]),
           {:ok, pdf_binary} <- Renderer.to_pdf(config["rendering"]["template"], data) do
        {:ok, pdf_binary}
      else
        {:ok, []} -> :no_results
      end
    end)
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
