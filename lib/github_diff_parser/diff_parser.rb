        when Regexes::INDEX_HEADER
          process_index(Regexp.last_match)
    # Called when encountering a `index abc..def` in the Git Diff output.
    #
    # @param match_data [MatchData]
    def process_index(match_data)
      validate_diff

      @current_diff.previous_index = match_data[:previous_index]
      @current_diff.new_index = match_data[:new_index]
    end
