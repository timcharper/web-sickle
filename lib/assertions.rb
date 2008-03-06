module WebSickle
  
  module Assertions
    def assert_equals(expected, actual, message = nil)
      unless(expected == actual)
        report_error <<-EOF
Error: Expected 
  #{actual.inspect}.to be
  #{expected.inspect}
#{message}
EOF
      end
    end

    def assert_select(selector, message)
      report_error("Error: Expected selector #{selector.inspect} to find a page element, but didn't. #{message}") if (@page / selector).blank?
    end

    def assert_no_select(selector, message)
      report_error("Error: Expected selector #{selector.inspect} to not find a page element, but did. #{message}") unless (@page / selector).blank?
    end

    def assert_contains(left, right, message = nil)
      right.each do | item |
        report_error("Error: Expected #{left.inspect} to contain #{right.inspect}, but didn't. #{message}") unless left.include?(item)
      end
    end
  end
  
end