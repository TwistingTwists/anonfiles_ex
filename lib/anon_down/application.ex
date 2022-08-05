defmodule AnonDown.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Downstream.start()

    children = [
      # Starts a worker by calling: AnonDown.Worker.start_link(arg)
      # {AnonDown.Worker, arg}
      # %{
      #   id: :downstream,
      #   start: {Downstream, :start, []},
      #   type: :worker,
      #   restart: :permanent,
      #   shutdown: 500
      # }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AnonDown.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
