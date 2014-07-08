Code.require_file("helpers/referers.exs", __DIR__)
Code.require_file("helpers/test_server.exs", __DIR__)

ExUnit.start()
ExReferer.TestHelper.TestServer.start()
