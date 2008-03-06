module WebSickle::Helpers
class TableReader
  attr_reader :headers, :options, :body_rows, :header_row, :extra_rows
  
  def initialize(element, p_options = {})
    @options = {
      :row_selectors => [" > tr", "thead > tr", "tbody > tr"],
      :header_selector => " > th",
      :header_proc => lambda { |th| th.inner_text.strip },
      :body_selector => " > td",
      :body_proc => lambda { |td| td.inner_text.strip },
      :header_offset => 0,
      :body_offset => 1
    }.merge(p_options)
    @options[:body_range] ||= options[:body_offset]..-1
    @rows = options[:row_selectors].map{|row_selector| element / row_selector}.compact.flatten
    
    @header_row = @rows[options[:header_offset]]
    @body_rows = @rows[options[:body_range]]
    @extra_rows = (options[:body_range].last+1)==0 ? [] : @rows[(options[:body_range].last+1)..-1]
    
    @headers = (@header_row / options[:header_selector]).map(&options[:header_proc])
  end
  
  def each_row(&block)
    @body_rows.map do |row|
      data_array = (row / options[:body_selector]).map(&options[:body_proc])
      data_hash = array_to_hash(data_array, @headers)
      yield data_hash if block_given?
      data_hash
    end
  end
  
  def array_to_hash(data, column_names)
    column_names.inject({}) {|h,column_name| h[column_name] = data[column_names.index(column_name)]; h }
  end
end
end