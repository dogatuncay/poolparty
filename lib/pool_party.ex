defmodule PoolParty do
  use Application

  def start(_, _) do
    strategy = :one_for_all

    children = [
      {PoolSup, {50, fn -> 2 end}},
      {Client, []}
    ]

    Supervisor.start_link(children, strategy: strategy, name: __MODULE__)
  end
end
