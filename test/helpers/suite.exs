defmodule ExReferer.TestHelper.Suite do
  defmacro __using__(_) do
    quote do
      setup_all do
        { :ok, _ } = ExReferer.Server.start_link([])

        ExReferer.TestHelper.Referers.yaml_fixture() |> ExReferer.load_yaml()
      end

      teardown_all do
        :ok = ExReferer.Server.stop()
      end
    end
  end
end
