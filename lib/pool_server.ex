defmodule PoolServer do
  use GenServer

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: __MODULE__)
  end

  defmodule State do
    @enforce_keys [:workers, :messages]
    defstruct [:workers, :messages]
  end

  @impl true
  def init(_) do
    IO.puts("Pool Server: #{inspect self()}")
    {:ok, %State{workers: %{}, messages: []}}
  end

  @impl true
  def handle_call({:ping, new_message}, _from, state) do
    messages = %{state | messages: [new_message|state.messages]}
    IO.puts new_message
    {:reply, messages, messages}
  end

  @impl true
  def handle_call({:register, worker_id}, {worker_pid, _}, state) do
    state = %{state | workers: Map.put(state.workers, worker_id, {worker_pid, :inactive})}
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:do_work, list}, {from, _}, state) do
    worker_data = find_inactive_worker(state.workers)
    if worker_data  do
      {worker_id, {worker_pid, _}} = worker_data
      state = %{state | workers: %{ state.workers | worker_id => {worker_pid, {:active, from}}}}
      GenServer.cast(worker_pid, {:submit_work, list})
      {:reply, :ok, state}
    else
      {:reply, :full, state}
    end
  end

  @impl true
  def handle_cast({:worker_finished, result, from}, state) do
    [{worker_id, {from, {:active, client_id}}}] = Enum.filter(state.workers, fn {_, value} ->
      case value do
        {pid, {:active, _}} -> pid == from
        {_, :inactive} -> false
        true -> raise "something is wrong"
      end
    end)

    state = %{state | workers: %{state.workers | worker_id => {from, :inactive}}}
    send(client_id, {:work_completed, result})
    {:noreply, state}
  end

  def find_inactive_worker(workers) do
    Enum.find(workers, nil, fn {_, value} ->
      case value do
        {_, {:active, _}} -> false
        {_, :inactive} -> true
        true -> raise "something is wrong"
      end
    end)
  end
end
