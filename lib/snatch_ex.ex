defmodule SnatchEx do
  @moduledoc false

  alias SnatchEx.{Fetcher, Scraper, Renderer}

  def snatch(search_text) do
    Enum.find_value(sites(), fn site ->
      with {:ok, html} <- Fetcher.search(site.search_url, search_text),
           base_url <- URI.to_string(%{URI.parse(site.search_url) | query: nil}),
           {:ok, [first_result | _]} <-
             Scraper.extract_results(html, site.results_selector, base_url),
           {:ok, target_html} <- Fetcher.fetch_page(first_result),
           {:ok, content} <- Scraper.extract_content(site.content_selector, target_html),
           {:ok, pdf_binary} <- Renderer.to_pdf(content) do
        {:ok, pdf_binary}
      else
        {:ok, []} -> :no_results
      end
    end)
  end

  defmodule SiteConfig do
    defstruct [:search_url, :results_selector, :content_selector, :base_url]

    @type t :: %__MODULE__{
            search_url: String.t(),
            results_selector: String.t(),
            content_selector: String.t(),
            base_url: String.t()
          }
  end

  defp sites do
    [
      %SnatchEx.SiteConfig{
        search_url: "https://example.com/tabs?search={query}",
        results_selector: "div.results-list > a",
        content_selector: "pre"
      }
    ]
  end
end
