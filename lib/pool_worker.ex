defmodule PoolWorker do
  use GenServer

  def start_link(init) do
    GenServer.start_link(__MODULE__, init)
  end

  @impl true
  def init({id, init_state}) do
    pid = Process.whereis(PoolServer)
    GenServer.call(pid, {:register, id})
    state = init_state.()
    {:ok, state}
  end

  @impl true
  def handle_cast({:submit_work, f}, state) do
    pid = Process.whereis(PoolServer)
    result = do_work(f, state)
    GenServer.cast(pid, {:worker_finished, result, self()})
    {:noreply, state}
  end

  def do_work(f, state) do
    :timer.sleep(5000)
    f.(state)
  end

end
