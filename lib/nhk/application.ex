defmodule Nhk.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Nhk.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nhk.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
