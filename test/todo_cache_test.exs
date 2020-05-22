defmodule TodoCacheTest do
  use ExUnit.Case
  @password "123456"

  setup_all do
    {:ok, todo_system_pid} = Todo.System.start_link()
    {:ok, todo_system_pid: todo_system_pid}
  end

  test "auth_server_process" do
    auth_pid = Todo.Cache.server_process("auth_server")
    assert auth_pid == Todo.Cache.server_process("auth_server")
  end

end
