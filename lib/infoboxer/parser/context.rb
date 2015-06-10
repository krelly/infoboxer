# encoding: utf-8
module Infoboxer
  class Parser
    class Context
      attr_reader :lineno
      attr_reader :traits

      def initialize(text, traits = nil)
        @lines = text.
          gsub(/<!--.+?-->/m, ''). # FIXME: will also kill comments inside <nowiki> tag
          split(/[\r\n]/)
        @lineno = -1
        @traits = traits || MediaWiki::Traits.default
        @scanner = StringScanner.new('')
        next!
      end

      # lines navigation
      def current
        @scanner ? @scanner.rest : ''
      end
      
      def next_lines
        @lines[(lineno+1)..-1]
      end

      def next!
        shift(+1)
      end

      def prev!
        shift(-1)
      end

      def eof?
        lineno >= @lines.count ||
          next_lines.empty? && eol?
      end

      def inspect
        "#<Context(line #{lineno} of #{@lines.count}: #{current})>"
      end

      # scanning
      def scan(re)
        @scanner.scan(re)
      end

      def check(re)
        @scanner.check(re)
      end

      def rest
        @scanner.rest
      end

      def skip(re)
        @scanner.skip(re)
      end

      def scan_until(re, leave_pattern = false)
        guard_eof!
        
        res = @scanner.scan_until(re)
        res[@scanner.matched] = '' if res && !leave_pattern
        res
      end

      def matched
        @scanner && @scanner.matched
      end

      def matched_inline?(re)
        re.nil? ? (matched.empty? && eol?) : matched =~ re
      end

      def matched?(re)
        re && matched =~ re
      end

      def eol?
        !current || current.empty?
      end

      def inline_eol?
        # not using StringScanner#check, as it will change #matched value
        eol? ||
          current =~ %r[^(</ref>|}})] 
      end

      def rewind(count)
        @scanner.pos -= count
      end

      def scan_continued_until(re, leave_pattern = false)
        res = ''
        
        loop do
          chunk = @scanner.scan_until(re)
          case @scanner.matched
          when re
            res << chunk
            break
          when nil
            res << @scanner.rest << "\n"
            next!
            eof? && fail!("Unfinished scan: #{re} not found")
          end
        end
        
        res[/#{re}\Z/] = '' unless leave_pattern
        res
      end

      def fail!(text)
        fail(ParsingError, "#{text} at line #{@lineno}:\n\t#{current}")
      end

      private

      def guard_eof!
        eof? and fail!("End of input reached")
      end

      def shift(amount)
        @lineno += amount
        current = @lines[lineno]
        if current
          @scanner.string = current
        else
          @scanner = nil
        end
      end
    end
  end
end