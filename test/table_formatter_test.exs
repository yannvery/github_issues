defmodule TableFormatterTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias Issues.TableFormatter, as: TF

  def data do
    [
      [number: 12345, title: "Title", description: "Long description"],
      [number: 848484848, title: "This is an issue", description: "simple description"],
      [number: 9876, title: "LOL", description: "full description"]
    ]
  end

  def data_column do
    [["Long description", "simple description", "very long full description"],
     ["12345", "0123456789", "1234578"]]
  end

  describe "split_into_columns" do
    test "the full data" do
      expected = [["12345", "848484848", "9876"],
                  [ "Title", "This is an issue", "LOL"],
                  ["Long description", "simple description", "full description"]]
      assert TF.split_into_columns(data(), [:number, :title, :description]) == expected
    end

    test "two columns" do
      expected = [["Long description", "simple description", "full description"],
                  ["12345", "848484848", "9876"]]
      assert TF.split_into_columns(data(), [:description, :number]) == expected
    end
  end

  test "widths_of" do
    assert TF.widths_of(data_column()) == [26, 10]
  end

  test "format_for" do
    assert TF.format_for([26, 10]) == "~-26s | ~-10s~n"
  end

  test "separator" do
    assert TF.separator([26, 10]) == "---------------------------+-----------"
  end

  test "puts_one_line_with_format" do
    result = capture_io fn ->
      TF.puts_one_line_with_format(["12345", "Long text"], "~5s | ~9s~n")
    end
    assert result == "12345 | Long text\n"
  end

  test "puts_in_columns" do
    result = capture_io fn ->
      TF.puts_in_columns(data_column(), "~26s | ~10s~n")
    end
    assert result ==
      """
                Long description |      12345
              simple description | 0123456789
      very long full description |    1234578
      """
  end

  test "print_table_for_columns" do
    result = capture_io fn ->
      TF.print_table_for_columns(data(), [:title, :number, :description])
    end
    assert result ==
      """
      title            | number    | description       \
      \n-----------------+-----------+-------------------
      Title            | 12345     | Long description  \
      \nThis is an issue | 848484848 | simple description
      LOL              | 9876      | full description  \

      """
  end
end
