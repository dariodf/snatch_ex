defmodule SnatchEx.Scraper do
  defmodule SiteConfig do
    defstruct [:search_url, :results_selector, :content_selector, :base_url]

    @type t :: %__MODULE__{
            search_url: String.t(),
            results_selector: String.t(),
            content_selector: String.t(),
            base_url: String.t()
          }
  end

  alias __MODULE__.SiteConfig

  def extract_results(%SiteConfig{results_selector: selector, base_url: base}, html) do
    html
    |> Floki.parse_document!()
    |> Floki.find(selector)
    |> Floki.attribute("href")
    |> Enum.map(&(base |> URI.merge(&1) |> URI.to_string()))
    |> then(&{:ok, &1})
  end

  def extract_content(%SiteConfig{content_selector: selector}, html) do
    html
    |> Floki.parse_document!()
    |> Floki.find(selector)
    |> Floki.text()
    |> then(&{:ok, %{content: &1}})
  end
end
