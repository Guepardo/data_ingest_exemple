defmodule Consumer do
  use ConsumerSupervisor

  def start_link(:ok) do
    children = [
      worker(Processor, [], restart: :temporary)
    ]

    ConsumerSupervisor.start_link(children,
      strategy: :one_for_one,
      subscribe_to: [
        {
          Producer,
          max_demand: 10, min_demand: 1
        }
      ]
    )
  end
end
