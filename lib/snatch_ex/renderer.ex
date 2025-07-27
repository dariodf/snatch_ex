defmodule SnatchEx.Renderer do
  def to_pdf(data) do
    """
    <pre style="font-size:10px;">
    #{data.content}
    </pre>
    """
    |> PdfGenerator.generate_binary()
  end
end
