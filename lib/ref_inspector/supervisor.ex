defmodule RefInspector.Supervisor do
  @moduledoc """
  This supervisor module takes care of starting the required database storage
  processes. It is automatically started with the `:ref_inspector` application.

  If you do not want to automatically start the application itself you can
  adapt your configuration for a more manual supervision approach.

  Instead of adding `:ref_inspector` to your `:applications` list or using
  the automatic discovery you need to add it to your `:included_applications`:

      def application do
        [
          included_applications: [
            # ...
            :ref_inspector,
            # ...
          ]
        ]
      end

  That done you can add `RefInspector.Supervisor` to your hierarchy:

      children = [
        # ...
        RefInspector.Supervisor,
        # ..
      ]
  """

  use Supervisor

  @doc false
  def start_link(default \\ nil) do
    Supervisor.start_link(__MODULE__, default, name: __MODULE__)
  end

  @doc false
  def init(_state) do
    Supervisor.init(
      [RefInspector.Database],
      strategy: :one_for_one
    )
  end
end
