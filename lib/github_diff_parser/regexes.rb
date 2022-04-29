# frozen_string_literal: true

module GithubDiffParser
  module Regexes
    # This Regexp is used to match the very first line of a diff.
    #
    # @example Possible header on a diff.
    #
    #   diff --git a/app/my_file.rb b/app/my_file.rb    <-- Match this line -->
    #   index d3dfbe4..ac0e8b3 100644
    #   --- a/app/my_file.rb
    #   +++ b/app/my_file.rb
    #   @@ -5,6 +5,6 @@ def test1
    DIFF_HEADER = %r{
      \A                                               # Start of line
      diff\s--git\s                                    # Match 'diff --git '
      a/(?<previous_filename>.*?)\s                    # Match 'a/filename.json ' and capture the "filename.json" part
      b/(?<new_filename>.*?)                           # Match 'b/filename.json ' and capture the "filename.json" part
      \Z                                               # End of line
    }x

    # This Regexp is used to match the header containing the original filename.
    #
    # @example Possible header on a diff.
    #
    #   diff --git a/app/my_file.rb b/app/my_file.rb
    #   index d3dfbe4..ac0e8b3 100644
    #   --- a/app/my_file.rb                            <-- Match this line -->
    #   +++ b/app/my_file.rb
    #   @@ -5,6 +5,6 @@ def test1
    ORIGINAL_FILE_HEADER = %r{
      \A                                               # Start of line
      ---\s.*                                          # Match '--- a/filename.rb' and capture the "filename.rb" part
      \Z                                               # End of line
    }x

    # This Regexp is used to match the header containing the new filename.
    #
    # @example Possible header on a diff.
    #
    #   diff --git a/app/my_file.rb b/app/my_file.rb
    #   index d3dfbe4..ac0e8b3 100644
    #   --- a/app/my_file.rb
    #   +++ b/app/my_file.rb                            <-- Match this line -->
    #   @@ -5,6 +5,6 @@ def test1
    NEW_FILE_HEADER = %r{
      \A                                               # Start of line
      \+\+\+\s.*                                       # Match '+++ b/filename.rb' and capture the "filename.rb" part
      \Z                                               # End of line
    }x

    # This Regexp is used to match the header indicating when a new file is added or removed.
    #
    # @example Possible header on a diff when adding a file.
    #
    #   diff --git a/blabla.rb b/blabla.rb
    #   new file mode 100644                           <-- Match this line -->
    #   index 0000000..d3dfbe4
    #   --- /dev/null
    #   +++ b/blabla.rb
    #   @@ -0,0 +1,10 @@
    #
    # @example Possible header on a diff when deleting a file.
    #
    #   diff --git a/package.json b/package.json
    #   deleted file mode 100644                      <-- Match this line -->
    #   index 3ffb801..0000000
    #   --- a/package.json
    #   +++ /dev/null
    #   @@ -1,11 +0,0 @@
    MODE_HEADER = %r{
      \A                                               # Start of line
      (?<file_mode>new|deleted)                        # Match 'new' or 'deleted' and capture the group
      \sfile\smode\s\d+                                # Match ' file mode 100655'
      \Z                                               # End of line
    }x

    # This Regexp is used to match the hunk's range of a diff.
    #
    # @example Possible hunk range on a diff.
    #
    #   diff --git a/app/my_file.rb b/app/my_file.rb
    #   index d3dfbe4..ac0e8b3 100644
    #   --- a/app/my_file.rb
    #   +++ b/app/my_file.rb
    #   @@ -5,6 +5,6 @@ def test1                     <-- Match this line -->
    #
    # @example Alternative match
    #
    #   diff --git a/app/my_file.rb b/app/my_file.rb
    #   index d3dfbe4..ac0e8b3 100644
    #   --- a/app/my_file.rb
    #   +++ b/app/my_file.rb
    #   @@ -5 +5 @@ def test1                         <-- Match this line -->
    RANGE_HEADER = %r{
      \A                                               # Start of line
      @@\s                                             # Match '@@ '
      -(?<previous_lino_start>\d+)(,\d+)?\s            # Match '-1,11 ' or match '-1 ' and capture the '1' part
      \+(?<new_lino_start>\d+)(,\d+)?\s                # Match '+1,34 ' or match '+1 ' and capture the '1' part
      @@.*                                             # Match '@@ Any text'
      \Z                                               # End of line
    }x

    # This Regexp is used to match added lines.
    #
    # @example Diff when a line is added.
    #
    #   diff --git a/app/my_file.rb b/app/my_file.rb
    #   index d3dfbe4..03d99f2 100644
    #   --- a/app/my_file.rb
    #   +++ b/app/my_file.rb
    #   @@ -6,5 +6,6 @@ def test1
    #
    #      def test2
    #        "This file is just added"
    #   +    "This is a new line"                   <-- Match this line -->
    #      end
    #    end
    #
    # @example Diff when a line is removed.
    #
    #   diff --git a/app/my_file.rb b/app/my_file.rb
    #   index 03d99f2..d3dfbe4 100644
    #   --- a/app/my_file.rb
    #   +++ b/app/my_file.rb
    #   @@ -6,6 +6,5 @@ def test1
    #
    #      def test2
    #        "This file is just added"
    #   -    "This is a new line"                      <-- Match this line -->
    #      end
    #    end
    #
    # @example Diff containing a contextual line.
    #
    #   diff --git a/app/my_file.rb b/app/my_file.rb
    #   index 03d99f2..d3dfbe4 100644
    #   --- a/app/my_file.rb
    #   +++ b/app/my_file.rb
    #   @@ -6,6 +6,5 @@ def test1
    #                                                  <-- Match this line -->
    #      def test2                                   <-- Match this line -->
    #        "This file is just added"                 <-- Match this line -->
    #   -    "This is a new line"
    #      end                                         <-- Match this line -->
    #    end                                           <-- Match this line -->
    LINE_DIFF = %r{
      \A                                               # Start of line
      (?<type>                                         # Named group <type>
        \+                                             # Match '+' (Considered as an addition line)
        |                                              # OR
        -                                              # Match '-' (Considered as a deletion line)
        |                                              # OR
        \s                                             # Match empty space ' ' (Considered as a contextual line)
      )                                                # End of named group
      (?<line>.*)                                      # Match the content of the line itself
      \Z                                               # End of line
    }x

    # This Regexp is used to match the first line of a resulting git format-patch.
    #
    # @example Match the line and capture the commit sha
    #   From 21e02a7fd129a0c17e3dfbf39c6e69240c3dc3d2 Mon Sep 17 00:00:00 2001
    PATCH_COMMIT = %r{
      \A                                              # Start of line
      From\s                                          # Match 'From '
      (?<commit>[a-z0-9]+)                            # Match the commit sha and capture it
      \s.*                                            # Match the remaining of the line ' Mon Sep 17 00:00:00 2001'
      \Z                                              # End of line
    }x

    # This Regexp is used to match the timestamp of the commit.
    #
    # @example Match the line and capture the timestamp
    #   Date: Fri, 15 Apr 2022 12:22:33 +0200
    PATCH_COMMIT_TIMESTAMP = %r{
      \A                                             # Start of line
      Date:\s(?<timestamp>.*)                        # Match 'Date: Fri, 15 Apr 2022 12:22:33 +0200'
      \Z                                             # End of line
    }x
  end
end
