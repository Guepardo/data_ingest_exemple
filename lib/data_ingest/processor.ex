defmodule Processor do
  def start_link(event) do

    Task.start_link(fn ->
      IO.puts("Processing event..")

      event
      |> :queue.to_list()
      |> Enum.count()
      |> IO.puts()

      :timer.sleep(1000)
    end)
  end
end
