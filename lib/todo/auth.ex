defmodule Todo.Auth do
  @name_key "username"
  @password_key "password"

  def process(auth, name) do
    choose_loop(auth, name)
  end

  def choose_loop(server, name) do
    case String.trim(IO.gets("Are you going to login, no for sign up[y/n/exit]:")) do      
      "y" -> 
        login_loop(server, name)
      "n" -> 
        new_user_check(server, name)
      "exit" -> 
        False
       _ -> 
        IO.puts "wrong input, There 3 valid input: 'y' for yes;'n' for no; 'exit' for exit."
        choose_loop(server, name)
    end
  end

  defp login_loop(server, name) do
    password = String.trim(IO.gets "user login_loop page:\nusername: #{name}\npassword[enter password]: ")
    [%{@password_key=>value}] = Todo.Server.entries(server, @name_key, name)
    cond do
      password == value ->
        IO.puts "login success, welcom back :)"
        true
      true ->
        IO.puts "confirm password doesn't match, please try again"
        register_loop(server, name)
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
        login_loop(server, name)
      true ->
        IO.puts "confirm password doesn't match, please try again"
        register_loop(server, name)
    end
  end
end