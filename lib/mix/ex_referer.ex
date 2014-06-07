defmodule Mix.ExReferer do
  def local_yaml(), do: Path.join(Mix.Utils.mix_home, "ex_referer/referers.yml")
end
