defmodule ExReferer.TestHelper.Suite do
  defmacro __using__(_) do
    quote do
      setup do
        { :ok, _ } = ExReferer.Server.start_link([])

        on_exit fn ->
          :ok = ExReferer.Server.stop()
        end

        ExReferer.TestHelper.Referers.yaml_fixture() |> ExReferer.load_yaml()
      end
    end
  end
end
