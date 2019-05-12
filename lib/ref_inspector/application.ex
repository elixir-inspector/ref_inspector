defmodule RefInspector.Application do
  @moduledoc false

  use Application

  def start(_type, _args), do: RefInspector.Supervisor.start_link()
end
