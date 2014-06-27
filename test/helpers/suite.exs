defmodule ExReferer.TestHelper.Suite do
  defmacro __using__(_) do
    quote do
      setup do
        { :ok, pid } = ExReferer.Server.start_link([])

        on_exit fn ->
          if Process.alive?(pid) do
            Process.exit(pid, :kill)
          end
        end

        ExReferer.TestHelper.Referers.yaml_fixture() |> ExReferer.load_yaml()
      end
    end
  end
end
