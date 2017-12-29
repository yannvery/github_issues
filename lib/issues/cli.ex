defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to functions
  that generate a table of last n issues of a github project
  """

  def run(argv) do
    parse_args(argv)
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  Otherwise it is a github user name, project and the munber of entries

  Retriem a tuple of `{user, project, count}`, or :help.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    case parse do
      {[help: true], _, _} -> :help
      {_, [user, project, count], _} -> {user, project, String.to_integer(count)}
      {_, [user, project], _} -> {user,project, @default_count}
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [count | #{@default_count}]
    """
    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> sort_into_ascending_order
    |> Enum.take(count)
    |> print_table_for_columns(["number", "created_at", "title"])
  end

  def decode_response({:ok, body}), do: body
  def decode_response({:error, error}) do
    message = Map.get(error, "message")
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2)
  end

  def sort_into_ascending_order(list_of_issues) do
    Enum.sort(list_of_issues,
              fn(i1, i2) -> Map.get(i1, "created_at") <= Map.get(i2, "created_at") end)
  end

  def print_table_for_columns(list_of_issues, columns) do
    n_trail = Enum.max(list_of_issues, fn(x) -> String.length(x["number"]) end) |> Map.get("number") |> to_string |> String.length
    c_trail = Enum.max(list_of_issues, fn(x) -> String.length(x["created_at"]) end) |> Map.get("created_at") |> String.length
    t_trail = Enum.max(list_of_issues, fn(x) -> String.length(x["title"]) end) |> Map.get("title") |> String.length

    IO.puts "#{n_trail} - #{c_trail} - #{t_trail}"

    head = ""
    |> Kernel.<> String.pad_trailing("#", n_trail  )
    |> Kernel.<>(" | ")
    |> Kernel.<> String.pad_trailing("created_at", c_trail )
    |> Kernel.<>(" | ")
    |> Kernel.<> String.pad_trailing("titile", t_trail )
    |> Kernel.<> "\n"
    |> Kernel.<> String.pad_leading("-", n_trail , "-")
    |> Kernel.<>(" + ")
    |> Kernel.<> String.pad_leading("-", c_trail , "-")
    |> Kernel.<>(" + ")
    |> Kernel.<> String.pad_leading("-", t_trail , "-")

    IO.puts head
    for issue <- list_of_issues do
      line = ""
             |> Kernel.<>(String.pad_trailing(to_string(issue["number"]), n_trail ))
             |> Kernel.<>(" | ")
             |> Kernel.<>(String.pad_trailing(issue["created_at"], c_trail  ))
             |> Kernel.<>(" | ")
             |> Kernel.<>(String.pad_trailing(issue["title"], t_trail ))
      IO.puts line
    end
  end
end
