defmodule SnatchEx.Application do
  use Application

  def start(_type, _args) do
    LoggerTelegramBackend.attach()

    children = [
      {Finch, name: SnatchEx.Finch},
      SnatchEx.Bot.PollingHandler
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: SnatchEx.Supervisor)
  end
end
