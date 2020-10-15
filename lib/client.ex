defmodule Client do

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, name: __MODULE__}
    }
  end

  def start_link(_) do
    pid = spawn_link &run/0
    {:ok, pid}
  end

  def run() do
    pid = Process.whereis(PoolServer)
    GenServer.call(pid, {:do_work, [1, 2, 3]})

    receive do
      {:work_completed, result} ->
        IO.puts "result: #{inspect result}"
        run()
    end
  end
end
