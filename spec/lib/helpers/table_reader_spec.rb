require File.dirname(__FILE__) + '/../../spec_helper'

describe WebSickle::Helpers::TableReader do
  before(:each) do
    @content = <<-EOF
<table>
  <tr>
    <th>Name</th>
    <th>Age</th>
  </tr>
  <tr>
    <td>Googly</td>
    <td>2</td>
  </tr>
</table>    
EOF
    h = Hpricot(@content)
    @table = WebSickle::Helpers::TableReader.new(h / "table")
  end
  
  it "should extract headers" do
    @table.headers.should == ["Name", "Age"]
  end
  
  it "should iterate through all rows" do
    @table.each_row do |row|
      row.keys.sort.should == ["Age", "Name"]
    end
  end
end