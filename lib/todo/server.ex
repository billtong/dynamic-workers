defmodule Todo.Server do
  use GenServer, restart: :temporary
  @server_name "auth_server"

  @doc """
  an authentification module before starting the server 
  """
  def start_link(name) do
    cond do
      name == @server_name -> 
        GenServer.start_link(Todo.Server, name, name: via_tuple(name))
      name != @server_name ->
        auth_check(name)
    end
  end

  def auth_check(name) do
    server = GenServer.start_link(Todo.Server, @server_name, name: via_tuple(@server_name))
    auth = filter_pid(server)
    cond do
      Todo.Auth.process(auth, name) ->
        GenServer.start_link(Todo.Server, name, name: via_tuple(name))
      True -> 
        IO.puts "Authentification Failed, Please try again."
    end
  end

  def filter_pid(server) do
    case server do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid 
    end
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, key, search) do
    GenServer.call(todo_server, {:entries, key, search})
  end

  def via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  @doc """
  check auth.
  print log start info, chose one out of 3 database process based on the hash of name string
  """
  @impl GenServer
  def init(name) do
    IO.puts("Starting to-do server for #{name}...")
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()}}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_call({:entries, key, search}, _, {name, todo_list}) do
    {
      :reply,
      Todo.List.entries(todo_list, key ,search),
      {name, todo_list}
    }
  end
end
