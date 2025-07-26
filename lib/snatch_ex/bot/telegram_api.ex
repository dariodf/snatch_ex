defmodule SnatchEx.Bot.TelegramAPI do
  @finch SnatchEx.Finch
  @api_url "https://api.telegram.org"

  def send_pdf(chat_id, filename, pdf_binary, caption \\ nil) do
    boundary = "----Boundary#{System.unique_integer([:positive])}"

    # Build multipart body manually
    body = [
      "--#{boundary}\r\n",
      "Content-Disposition: form-data; name=\"chat_id\"\r\n\r\n",
      "#{chat_id}\r\n",
      if caption do
        [
          "--#{boundary}\r\n",
          "Content-Disposition: form-data; name=\"caption\"\r\n\r\n",
          "#{caption}\r\n"
        ]
      else
        []
      end,
      "--#{boundary}\r\n",
      "Content-Disposition: form-data; name=\"document\"; filename=\"#{filename}.pdf\"\r\n",
      "Content-Type: application/pdf\r\n\r\n",
      pdf_binary,
      "\r\n--#{boundary}--\r\n"
    ]

    headers = [
      {"content-type", "multipart/form-data; boundary=#{boundary}"}
    ]

    body_binary = IO.iodata_to_binary(body)

    token = Application.fetch_env!(:telegex, :token)
    url = "#{@api_url}/bot#{token}/sendDocument"

    {:ok, %Finch.Response{status: 200}} =
      Finch.build(:post, url, headers, body_binary)
      |> Finch.request(@finch)
  end
end
