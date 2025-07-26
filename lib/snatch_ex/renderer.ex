defmodule SnatchEx.Renderer do
  @page_width 595  # A4 width in points
  @left_margin 40
  @top_margin 800
  @line_spacing 11

  @font_name "Courier"  # built-in monospace font
  @font_size 8

  def to_pdf(text) when is_binary(text) do
    {:ok, pdf_pid} = Pdf.new([size: :a4, compress: true])

    pdf_pid
    |> Pdf.set_info(title: "SnatchEx PDF")
    |> Pdf.set_font(@font_name, @font_size)
    |> render_lines(text)
    |> Pdf.export()
    |> then(fn pdf_binary ->
      Pdf.cleanup(pdf_pid)
      {:ok, pdf_binary}
    end)
  end

  defp render_lines(pdf_pid, text) do
    lines =
      text
      |> String.split("\n", trim: true)
      |> Enum.flat_map(&wrap_line(&1, 100))  # You can increase this for monospace

    Enum.reduce(lines, @top_margin, fn line, y ->
      Pdf.text_at(pdf_pid, {@left_margin, y}, line)
      y - @line_spacing
    end)

    pdf_pid
  end

  defp wrap_line(line, max_chars) when is_binary(line) do
    line
    |> String.graphemes()
    |> Enum.chunk_every(max_chars)
    |> Enum.map(&Enum.join/1)
  end
end
