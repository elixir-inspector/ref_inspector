defmodule ExReferer.TestHelper.TestServer do
  def start() do
    ExReferer.start_link()
    ExReferer.load_yaml(ExReferer.TestHelper.Referers.yaml_fixture())
  end
end
