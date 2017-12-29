defmodule Issues.TableFormatter do

  def print_table_for_columns(rows, headers) do
    with data_by_columns = split_into_columns(rows, headers),
         widths = widths_of(data_by_columns),
         format = format_for(widths)
    do
      puts_one_line_with_format(headers, format)
      IO.puts separator(widths)
      puts_in_columns(data_by_columns, format)
    end
  end

  def split_into_columns(rows, headers) do
    for header <- headers do
      for row <- rows do
        print_data(row[header])
      end
    end
  end

  def print_data(value) when is_binary(value) do
    value
  end

  def print_data(value) when is_integer(value) do
    Integer.to_string(value)
  end

  def widths_of(columns) do
    for data <- columns do
      data
      |> Enum.map(fn(x) -> String.length(x) end)
      |> Enum.max
    end
  end

  def format_for(columns_width) do
    Enum.map_join(columns_width, " | ", fn(w) -> "~-#{w}s" end) <> "~n"
  end

  def separator(columns_width) do
    Enum.map_join(columns_width, "-+-", fn(w) -> List.duplicate("-", w) end)
  end

  def puts_one_line_with_format(data, format) do
    :io.format(format, data)
  end

  def puts_in_columns(data_by_columns, format) do
    data_by_columns
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.each(&puts_one_line_with_format(&1, format))
  end
end
