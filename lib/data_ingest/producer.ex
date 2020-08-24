defmodule Producer do
  use GenStage

  @batch_size 1_000

  def start_link(_) do
    GenStage.start(__MODULE__, :ok, name: __MODULE__)
  end

  def ingest(event) do
    GenStage.cast(__MODULE__, {:ingest, event})
  end

  # CALLBACKS

  def init(:ok) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_cast({:ingest, event}, {queue, pending_demand}) do
    dispatch_events(:queue.in(event, queue), pending_demand, [])
  end

  def handle_demand(incoming_demand, {queue, pending_demand}) do
    dispatch_events(queue, incoming_demand + pending_demand, [])
  end

  defp dispatch_events(queue, 0, events) do
    {:noreply, events, {queue, 0}}
  end

  defp dispatch_events(queue, demand, events) do
    case split_queue(queue) do
      {:ok, {batch_events, remaing_queue}} ->
        dispatch_events(remaing_queue, demand - 1, [batch_events | events])

      {:not_enougth} ->
        {:noreply, events, {queue, demand}}
    end
  end

  def split_queue(queue) do
    cond do
      :queue.len(queue) < @batch_size ->
        {:not_enougth}

      true ->
        {:ok, :queue.split(@batch_size, queue)}
    end
  end
end
