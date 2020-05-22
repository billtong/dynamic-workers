defmodule Todo.Auth do
  @name_key "username"
  @password_key "password"

  @doc """
  this is for cli
  """
  def process(server, name) do
    case String.trim(IO.gets("Are you going to login, no for sign up[y/n/exit]:")) do      
      "y" -> 
        login_username_check(server, name)
      "n" -> 
        new_user_check(server, name)
      "exit" -> 
        false
       _ -> 
        IO.puts "wrong input, There 3 valid input: 'y' for yes;'n' for no; 'exit' for exit."
        process(server, name)
    end
  end

  defp login_username_check(server, name) do
    try do
      list = Todo.Server.entries(server, @name_key, name)
      cond do
        list == [] || list == nil ->
          IO.puts("user not exist! please try again")
          false
        true ->
          IO.puts "user check result: exit"
          login_password_check(server, name, list)
      end
    rescue
      e in RuntimeError -> IO.puts("user not exist! please try again")
      false
    end
  end

  defp login_password_check(server, name, [%{@password_key=>value}] = list) do
    password = String.trim(IO.gets "user login_loop page:\nusername: #{name}\npassword[enter password]: ")
    cond do
      password == value ->
        IO.puts "login success, welcom back :)"
        true
      true ->
        IO.puts "confirm password doesn't match, please try again"
        login_password_check(server, name, list)
    end
  end

  defp new_user_check(server, name) do
    list = Todo.Server.entries(server, @name_key, name)
    cond do
      length(list) > 0 ->
        IO.puts "Error: the user name '#{name}' has already been taken by others, please exit and change another username"
        false
      True ->
        register_loop(server, name)
    end
  end

  defp register_loop(server, name) do
    password = String.trim(IO.gets "user register_loop page:\nusername: #{name}\nnew password[enter password]: ")
    confirm = String.trim(IO.gets "confirm password[enter password]: ")
    cond do
      password == confirm ->
        user = %{@name_key=>name, @password_key=>password}
        Todo.Server.add_entry(server, user)
        IO.puts "register success, redirecting to login page..."
        login_username_check(server, name)
      true ->
        IO.puts "confirm password doesn't match, please try again"
        register_loop(server, name)
    end
  end
end