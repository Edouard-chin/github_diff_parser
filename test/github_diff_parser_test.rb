# frozen_string_literal: true

require "test_helper"

class GithubDiffParserTest < Minitest::Test
  def test_boom1
    refute(true)
  end

  def test_boom2
    assert(false)
  end

  def test_boom3
    flunk
  end

  def test_line_added
    parsed_diffs = GithubDiffParser.parse(read_diff("line_added"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("app/my_file.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(6, hunk.lines.count)
    assert_equal(5, hunk.contextual_lines.count)
    assert_equal(1, hunk.addition_lines.count)

    expected_lines = [
      { previous_number: 6, current_number: 6, patch_position: 1, type: :contextual? },
      { previous_number: 7, current_number: 7, patch_position: 2, type: :contextual? },
      { previous_number: 8, current_number: 8, patch_position: 3, type: :contextual? },
      { previous_number: nil, current_number: 9, patch_position: 4, type: :addition? },
      { previous_number: 9, current_number: 10, patch_position: 5, type: :contextual? },
      { previous_number: 10, current_number: 11, patch_position: 6, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_line_removed
    parsed_diffs = GithubDiffParser.parse(read_diff("line_removed"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("app/my_file.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(6, hunk.lines.count)
    assert_equal(5, hunk.contextual_lines.count)
    assert_equal(1, hunk.deletion_lines.count)

    expected_lines = [
      { previous_number: 6, current_number: 6, patch_position: 1, type: :contextual? },
      { previous_number: 7, current_number: 7, patch_position: 2, type: :contextual? },
      { previous_number: 8, current_number: 8, patch_position: 3, type: :contextual? },
      { previous_number: 9, current_number: nil, patch_position: 4, type: :deletion? },
      { previous_number: 10, current_number: 9, patch_position: 5, type: :contextual? },
      { previous_number: 11, current_number: 10, patch_position: 6, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_line_changed
    parsed_diffs = GithubDiffParser.parse(read_diff("line_changed"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("app/my_file.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(7, hunk.lines.count)
    assert_equal(5, hunk.contextual_lines.count)
    assert_equal(1, hunk.deletion_lines.count)
    assert_equal(1, hunk.addition_lines.count)

    expected_lines = [
      { previous_number: 5, current_number: 5, patch_position: 1, type: :contextual? },
      { previous_number: 6, current_number: 6, patch_position: 2, type: :contextual? },
      { previous_number: 7, current_number: 7, patch_position: 3, type: :contextual? },
      { previous_number: 8, current_number: nil, patch_position: 4, type: :deletion? },
      { previous_number: nil, current_number: 8, patch_position: 5, type: :addition? },
      { previous_number: 9, current_number: 9, patch_position: 6, type: :contextual? },
      { previous_number: 10, current_number: 10, patch_position: 7, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_file_added
    parsed_diffs = GithubDiffParser.parse(read_diff("file_added"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("blabla.rb", parsed_diff.previous_filename)
    assert_equal("blabla.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)
    assert_predicate(parsed_diff, :new_mode?)

    hunk = parsed_diff.hunks.first
    assert_equal(10, hunk.lines.count)
    assert_equal(10, hunk.addition_lines.count)

    expected_lines = [
      { previous_number: nil, current_number: 1, patch_position: 1, type: :addition? },
      { previous_number: nil, current_number: 2, patch_position: 2, type: :addition? },
      { previous_number: nil, current_number: 3, patch_position: 3, type: :addition? },
      { previous_number: nil, current_number: 4, patch_position: 4, type: :addition? },
      { previous_number: nil, current_number: 5, patch_position: 5, type: :addition? },
      { previous_number: nil, current_number: 6, patch_position: 6, type: :addition? },
      { previous_number: nil, current_number: 7, patch_position: 7, type: :addition? },
      { previous_number: nil, current_number: 8, patch_position: 8, type: :addition? },
      { previous_number: nil, current_number: 9, patch_position: 9, type: :addition? },
      { previous_number: nil, current_number: 10, patch_position: 10, type: :addition? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_file_removed
    parsed_diffs = GithubDiffParser.parse(read_diff("file_removed"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("package.json", parsed_diff.previous_filename)
    assert_equal("package.json", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)
    assert_predicate(parsed_diff, :deleted_mode?)

    hunk = parsed_diff.hunks.first
    assert_equal(11, hunk.lines.count)
    assert_equal(11, hunk.deletion_lines.count)

    expected_lines = [
      { previous_number: 1, current_number: nil, patch_position: 1, type: :deletion? },
      { previous_number: 2, current_number: nil, patch_position: 2, type: :deletion? },
      { previous_number: 3, current_number: nil, patch_position: 3, type: :deletion? },
      { previous_number: 4, current_number: nil, patch_position: 4, type: :deletion? },
      { previous_number: 5, current_number: nil, patch_position: 5, type: :deletion? },
      { previous_number: 6, current_number: nil, patch_position: 6, type: :deletion? },
      { previous_number: 7, current_number: nil, patch_position: 7, type: :deletion? },
      { previous_number: 8, current_number: nil, patch_position: 8, type: :deletion? },
      { previous_number: 9, current_number: nil, patch_position: 9, type: :deletion? },
      { previous_number: 10, current_number: nil, patch_position: 10, type: :deletion? },
      { previous_number: 11, current_number: nil, patch_position: 11, type: :deletion? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_file_moved
    parsed_diffs = GithubDiffParser.parse(read_diff("file_moved"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("blabla.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(0, parsed_diff.hunks.count)
    assert_predicate(parsed_diff, :rename_mode?)
  end

  def test_rails_diff
    parsed_diffs = GithubDiffParser.parse(read_diff("rails"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("actionmailer/lib/action_mailer/railtie.rb", parsed_diff.previous_filename)
    assert_equal("actionmailer/lib/action_mailer/railtie.rb", parsed_diff.new_filename)
    assert_equal(2, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(7, hunk.lines.count)
    assert_equal(6, hunk.contextual_lines.count)
    assert_equal(1, hunk.deletion_lines.count)

    expected_lines = [
      { previous_number: 23, current_number: 23, patch_position: 1, type: :contextual? },
      { previous_number: 24, current_number: 24, patch_position: 2, type: :contextual? },
      { previous_number: 25, current_number: 25, patch_position: 3, type: :contextual? },
      { previous_number: 26, current_number: nil, patch_position: 4, type: :deletion? },
      { previous_number: 27, current_number: 26, patch_position: 5, type: :contextual? },
      { previous_number: 28, current_number: 27, patch_position: 6, type: :contextual? },
      { previous_number: 29, current_number: 28, patch_position: 7, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end

    hunk = parsed_diff.hunks[1]
    assert_equal(18, hunk.lines.count)
    assert_equal(6, hunk.contextual_lines.count)
    assert_equal(3, hunk.deletion_lines.count)
    assert_equal(9, hunk.addition_lines.count)

    expected_lines = [
      { previous_number: 46, current_number: 45, patch_position: 9, type: :contextual? },
      { previous_number: 47, current_number: 46, patch_position: 10, type: :contextual? },
      { previous_number: 48, current_number: 47, patch_position: 11, type: :contextual? },
      { previous_number: 49, current_number: nil, patch_position: 12, type: :deletion? },
      { previous_number: 50, current_number: nil, patch_position: 13, type: :deletion? },
      { previous_number: 51, current_number: nil, patch_position: 14, type: :deletion? },
      { previous_number: nil, current_number: 48, patch_position: 15, type: :addition? },
      { previous_number: nil, current_number: 49, patch_position: 16, type: :addition? },
      { previous_number: nil, current_number: 50, patch_position: 17, type: :addition? },
      { previous_number: nil, current_number: 51, patch_position: 18, type: :addition? },
      { previous_number: nil, current_number: 52, patch_position: 19, type: :addition? },
      { previous_number: nil, current_number: 53, patch_position: 20, type: :addition? },
      { previous_number: nil, current_number: 54, patch_position: 21, type: :addition? },
      { previous_number: nil, current_number: 55, patch_position: 22, type: :addition? },
      { previous_number: nil, current_number: 56, patch_position: 23, type: :addition? },
      { previous_number: 52, current_number: 57, patch_position: 24, type: :contextual? },
      { previous_number: 53, current_number: 58, patch_position: 25, type: :contextual? },
      { previous_number: 54, current_number: 59, patch_position: 26, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_when_range_header_has_no_comma
    parsed_diffs = GithubDiffParser.parse(read_diff("range_header_with_no_comma"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("app/my_file.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(7, hunk.lines.count)
    assert_equal(5, hunk.contextual_lines.count)
    assert_equal(1, hunk.deletion_lines.count)
    assert_equal(1, hunk.addition_lines.count)

    expected_lines = [
      { previous_number: 5, current_number: 5, patch_position: 1, type: :contextual? },
      { previous_number: 6, current_number: 6, patch_position: 2, type: :contextual? },
      { previous_number: 7, current_number: 7, patch_position: 3, type: :contextual? },
      { previous_number: 8, current_number: nil, patch_position: 4, type: :deletion? },
      { previous_number: nil, current_number: 8, patch_position: 5, type: :addition? },
      { previous_number: 9, current_number: 9, patch_position: 6, type: :contextual? },
      { previous_number: 10, current_number: 10, patch_position: 7, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_raise_when_diff_is_not_a_diff
    assert_raises(GithubDiffParser::InvalidDiff) do
      GithubDiffParser.parse(read_diff("invalid"))
    end
  end

  def test_raise_when_diff_header_is_missing
    assert_raises(GithubDiffParser::InvalidDiff) do
      GithubDiffParser.parse(read_diff("diff_header_missing"))
    end
  end

  def test_raise_when_diff_hunk_range_is_missing
    assert_raises(GithubDiffParser::InvalidDiff) do
      GithubDiffParser.parse(read_diff("hunk_range_missing"))
    end
  end

  def test_lines
    parsed_diffs = GithubDiffParser.parse(read_diff("line_added"))

    assert_equal(6, parsed_diffs[0].lines.count)
  end

  def test_index
    parsed_diffs = GithubDiffParser.parse(read_diff("line_added"))

    assert_equal("d3dfbe4", parsed_diffs[0].previous_index)
    assert_equal("03d99f2", parsed_diffs[0].new_index)
  end

  private

  def assert_equal(expected, *args)
    if expected.nil?
      assert_nil(*args)
    else
      super(expected, *args)
    end
  end

  def assert_line(expected, actual)
    assert_equal(
      expected[:previous_number],
      actual.previous_number,
      "The line previous number don't match. Expected: #{expected[:previous_number]}, Actual: #{actual.previous_number}"
    )

    assert_equal(
      expected[:current_number],
      actual.current_number,
      "The line actual number don't match. Expected: #{expected[:current_number]}, Actual: #{actual.current_number}"
    )

    assert_equal(
      expected[:patch_position],
      actual.patch_position,
      "The patch position don't match. Expected: #{expected[:patch_position]}, Actual: #{actual.patch_position}"
    )

    assert_predicate(actual, expected[:type])
  end
end
