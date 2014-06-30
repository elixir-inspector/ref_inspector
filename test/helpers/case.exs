defmodule ExReferer.TestHelper.Case do
  use ExUnit.CaseTemplate

  setup do
    { :ok, pid } = ExReferer.Server.start_link([])

    on_exit fn ->
      if Process.alive?(pid) do
        Process.exit(pid, :kill)
      end
    end

    ExReferer.TestHelper.Referers.yaml_fixture() |> ExReferer.load_yaml()
  end

  using do
    quote do
      import ExReferer.TestHelper.Case
    end
  end
end
