defmodule Mix.ExReferer do
  @moduledoc """
  Mix utility module.
  """

  @doc """
  Returns the path where the database file is downloaded to.
  """
  def local_yaml(), do: Path.join(Mix.Utils.mix_home, "ex_referer/referers.yml")
end
