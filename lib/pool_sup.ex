defmodule PoolSup do
  use Supervisor

  def start_link(init) do
    Supervisor.start_link(__MODULE__, init, name: __MODULE__)
  end

  def init({n, init_state}) do
    strategy = :one_for_all

    worker_children = Enum.map(1..n, fn index ->
      Supervisor.child_spec({PoolWorker, {index, init_state}}, %{ id: index})
    end)

    children = [{PoolServer, "hello"} | worker_children]
    Supervisor.init(children, strategy: strategy, name: __MODULE__)
  end
end
