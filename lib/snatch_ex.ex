defmodule SnatchEx do
  @moduledoc false

  alias SnatchEx.{Fetcher, Scraper, Renderer}

  def snatch(search_text) do
    Enum.find_value(sites(), fn site ->
      with {:ok, html} <- Fetcher.search(site["search_url"], search_text),
           base_url <- URI.to_string(%{URI.parse(site["search_url"]) | query: nil}),
           {:ok, [first_result | _]} <-
             Scraper.extract_results(html, site["results_selector"], base_url),
           {:ok, target_html} <- Fetcher.fetch_page(first_result),
           {:ok, data} <- Scraper.extract_contents(target_html, site["content_selectors"]),
           {:ok, pdf_binary} <- Renderer.to_pdf(site["template"], data) do
        {:ok, pdf_binary}
      else
        {:ok, []} -> :no_results
      end
    end)
  end

  defp sites do
    yaml = """
    - search_url: "https://gametabs.net/tabs?search={query}"
      results_selector: "div.results-list > a"
      content_selectors:
        content: "pre"
        name: "#tab-page-tab-name"
        band: "#tab-page-game-name"
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
