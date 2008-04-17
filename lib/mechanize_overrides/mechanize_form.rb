# this monkey patch fixes WWW::Mechanize::Form to behave more like web-browsers when encountering oddly typed controls (interpretting them as text-fields)
# submitted as patch:
# http://rubyforge.org/tracker/index.php?func=detail&aid=19613&group_id=1453&atid=5709
module WWW
  class Mechanize
    class Form
      private
      def parse
        @fields       = WWW::Mechanize::List.new
        @buttons      = WWW::Mechanize::List.new
        @file_uploads = WWW::Mechanize::List.new
        @radiobuttons = WWW::Mechanize::List.new
        @checkboxes   = WWW::Mechanize::List.new

        # Find all input tags
        (form_node/'input').each do |node|
          type = (node['type'] || 'text').downcase
          name = node['name']
          next if name.nil? && !(type == 'submit' || type =='button')
          case type
          when 'radio'
            @radiobuttons << RadioButton.new(node['name'], node['value'], node.has_attribute?('checked'), self)
          when 'checkbox'
            @checkboxes << CheckBox.new(node['name'], node['value'], node.has_attribute?('checked'), self)
          when 'file'
            @file_uploads << FileUpload.new(node['name'], nil) 
          when 'submit'
            @buttons << Button.new(node['name'], node['value'])
          when 'button'
            @buttons << Button.new(node['name'], node['value'])
          when 'image'
            @buttons << ImageButton.new(node['name'], node['value'])
          else
            @fields << Field.new(node['name'], node['value'] || '') 
          end
        end

        # Find all textarea tags
        (form_node/'textarea').each do |node|
          next if node['name'].nil?
          @fields << Field.new(node['name'], node.inner_text)
        end

        # Find all select tags
        (form_node/'select').each do |node|
          next if node['name'].nil?
          if node.has_attribute? 'multiple'
            @fields << MultiSelectList.new(node['name'], node)
          else
            @fields << SelectList.new(node['name'], node)
          end
        end
      end
    end
  end
end
