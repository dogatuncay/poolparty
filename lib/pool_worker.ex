defmodule PoolWorker do
  use GenServer

  def start_link(init) do
    GenServer.start_link(__MODULE__, init)
  end

  @impl true
  def init(id) do
    pid = Process.whereis(PoolServer)
    GenServer.call(pid, {:register, id})
    {:ok, []}
  end

  @impl true
  def handle_cast({:submit_work, list}, state) do
    pid = Process.whereis(PoolServer)
    result = do_work(list)
    GenServer.cast(pid, {:worker_finished, result, self()})
    {:noreply, state}
  end

  def do_work(list) do
    :timer.sleep(5000)
    Enum.sum(list)
  end

end
