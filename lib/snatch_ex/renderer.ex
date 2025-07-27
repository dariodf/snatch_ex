defmodule SnatchEx.Renderer do
  def to_pdf(template, data) do
    Enum.reduce(data, template, fn {key, value}, acc ->
      String.replace(acc, "{#{key}}", value)
    end)
    |> PdfGenerator.generate_binary()
  end
end
