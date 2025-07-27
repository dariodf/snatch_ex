defmodule SnatchEx.Bot.PollingHandler do
  use Telegex.Polling.GenHandler
  alias SnatchEx.Bot.TelegramAPI

  @impl true
  def on_boot do
    # delete any potential webhook
    {:ok, true} = Telegex.delete_webhook()
    # create configuration (can be empty, because there are default values)
    %Telegex.Polling.Config{}
  end

  @impl true
  def on_update(update) do
    %Telegex.Type.Update{
      poll_answer: _poll_answer,
      poll: _poll,
      callback_query: _callback_query,
      chosen_inline_result: _chosen_inline_result,
      inline_query: _inline_query,
      message: %Telegex.Type.Message{
        chat: %Telegex.Type.Chat{id: chat_id},
        reply_markup: _,
        text: text
      },
      update_id: _
    } = update

    case SnatchEx.snatch(text) do
      {:ok, pdf_binary, data} ->
        TelegramAPI.send_pdf(chat_id, "#{data["name"]} - #{data["band"]}", pdf_binary)
      {:error, :no_results} ->
        Telegex.send_message(chat_id, "No results for #{text}.")
    end

    :ok
  end
end
