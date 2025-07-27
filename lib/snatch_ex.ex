defmodule SnatchEx do
  @moduledoc false

  alias SnatchEx.{Fetcher, Scraper, Renderer}

  def snatch(search_text) do
    Enum.find_value(sites(), fn site_config ->
      with {:ok, html} <- Fetcher.search(site_config, search_text),
           {:ok, [first_result | _]} <- Scraper.extract_results(site_config, html),
           {:ok, target_html} <- Fetcher.fetch_page(first_result),
           {:ok, content} <- Scraper.extract_content(site_config, target_html),
           {:ok, pdf_binary} <- Renderer.to_pdf(content) do
        {:ok, pdf_binary}
      else
        {:ok, []} -> :no_results
      end
    end)
  end

  defp sites do
    [
      %Scraper.SiteConfig{
        search_url: "https://example.com/tabs?search={query}",
        results_selector: "div.results-list > a",
        content_selector: "pre",
        base_url: "https://example.com"
      }
    ]
  end
end
