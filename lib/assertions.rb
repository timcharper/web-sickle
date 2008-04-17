module WebSickle
  
  module Assertions
    def assert_equals(expected, actual, message = nil)
      unless(expected == actual)
        report_error <<-EOF
Error: Expected 
  #{expected.inspect}, but got
  #{actual.inspect}
#{message}
EOF
      end
    end

    def assert_select(selector, message)
      assert_select_in(@page, selector, message)
    end

    def assert_no_select(selector, message)
      assert_no_select_in(@page, selector, message)
    end

    def assert_select_in(content, selector, message)
      report_error("Error: Expected selector #{selector.inspect} to find a page element, but didn't. #{message}") if (content / selector).blank?
    end

    def assert_no_select_in(content, selector, message)
      report_error("Error: Expected selector #{selector.inspect} to not find a page element, but did. #{message}") unless (content / selector).blank?
    end

    def assert_contains(left, right, message = nil)
      right.each do | item |
        report_error("Error: Expected #{left.inspect} to contain #{right.inspect}, but didn't. #{message}") unless left.include?(item)
      end
    end
  end
  
end