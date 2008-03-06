module WebSickle
class Base
  
  # form_value is used to interface with the current select form
  attr_reader :form_value
  
  def initialize(options = {})
    @page = nil
    @pages = []
    @form_value = HashProxy.new(
      :set => lambda { |identifier, value| set_form_value(identifier, value)}, 
      :get => lambda { |identifier| get_form_value(identifier)}
    )
  end
  
  def login
    @logged_in = do_login
  end
  
  def logged_in?; @logged_in; end
  
  def harvest
    login unless logged_in?
    do_harvest
  end
  
  protected
    # expected - returns true / false depending on success
    def do_login
      raise "Implement me!"
    end
  
    # our friendly mechinze agent
    def agent
      @agent ||= new_mechanize_agent
    end
  
    def find_field(identifier)
      if @form.nil?
        report_error("No form is selected when trying to find field by #{identifier.inspect}")
        return
      end
      identifier = {:name => identifier} unless identifier.is_a?(Hash)
      identifier.assert_valid_keys(:name)
      field = find_in_collection(@form.fields + @form.checkboxes, identifier)
      if field
        field
      else
        report_error("Tried to find field identified by #{identifier.inspect}, but failed.\nForm fields are: #{@form.fields.map{|f| f.inspect} * ", \n  "}") 
        nil
      end
    end
  
    # finds a button by parameters.  Throws error if not able to find.
    # example:
    # find_button("btnSubmit") - finds a button named "btnSubmit"
    # find_button(:name => "btnSubmit")
    # find_button(:name => "btnSubmit", :value => /Lucky/) - finds a button named btnSubmit with a value matching /Lucky/
    def find_button(identifier)
      identifier = {:name => identifier} unless identifier.is_a?(Hash)
      identifier.assert_valid_keys(:value, :name)
      button = find_in_collection(@form.buttons, identifier)
      if button
        button
      else
        report_error("Tried to find button identified by #{identifier.inspect}, but failed.  Buttons on selected form are: #{@form.buttons.map{|f| f.inspect} * ','}") 
        nil
      end
    end
  
    # the magic method that powers find_button, find_field.  Does not throw an error if not found
    def find_in_collection(collection, identifier)
      collection.find do |item|
        identifier.all? { |k, criteria| is_a_match?(criteria, item.send(k)) }
      end
    end
  
    # submits the current form
    def submit_form(button_criteria = nil, options = {})
      button = 
        case button_criteria
        when :first_button
          @form.buttons.first
        when nil
          nil
        else
          find_button(button_criteria)
        end

      set_page(agent.submit(@form, button))
    end

    # sets a form-field's value by identifier.  Throw's error if field does not exist
    def set_form_value(identifier, value)
      field = find_field(identifier)
      case field
      when WWW::Mechanize::Form::CheckBox
        field.checked = value
      else
        field.value = value
      end
    end
  
    def set_form_values(set_pairs = {})
      set_pairs.each do |identifier, value|
        set_form_value(identifier, value
        )
      end
    end

    # sets a form-field's value by identifier.  Throw's error if field does not exist
    def get_form_value(identifier)
      field = find_field(identifier)
      case field
      when WWW::Mechanize::Form::CheckBox
        field.checked
      else
        field.value
      end
    end

    # open the current page somewhere else
    def open_page(path)
      set_page(agent.get(path))
    end
  
    # uses Hpricot style css selectors to find the element.  Works with html pages, and file pages that happen to have xml-like content.
    # throws error if can't find a match
    def select_element(match)
      result = (@page.respond_to?(:/) ? @page : Hpricot(@page.body)) / match
      if result.blank?
        report_error("Tried to find element matching #{match}, but couldn't")
      else
        result
      end
    end
  
    # select the current form
    def select_form(identifier = {})
      identifier = {:name => identifier} unless identifier.is_a?(Hash)
      identifier.assert_valid_keys(:name, :action, :method)
      @form = find_in_collection(@page.forms, identifier)
      report_error("Couldn't find form on page at #{@page.uri} with attributes #{identifier.inspect}") if @form.nil?
      @form
    end

    def report_error(msg)
      raise "Error encountered: #{msg}.\n\nPage URL:#{@page.uri.to_s}\nPage body:\n#{@page.body}"
    end
  
  private
    def set_page(p)
      @form = nil
      @pages << @page
      @page = p
      @page
    end

    def is_a_match?(criteria, value)
      case criteria
      when Regexp
        criteria.match(value)
      when String
        criteria == value
      when Array
        criteria.include?(value)
      end
    end
  
    def new_mechanize_agent
      a = WWW::Mechanize.new
      a.read_timeout = 600 # 10 minutes
      a
    end
  
end
  
end
