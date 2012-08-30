class Dataset::Pb_core < Dataset::Xml
  def content
    super.gsub(/(<\/?[A-Za-z0-9_]+):/) { $1 } 
  end

  protected
  def process_record row, solr_doc = nil
    solr_doc ||= {}
    fields = []
    row.xpath("*").select { |x| !x.text.blank? }.each do |node|
      case node.name
        when "pbcoreIdentifier"
	     a_v = "CAN_NUMBER"
             
	     if node.values()[0] == a_v
               fields << ["#{node.name.parameterize}_s", node.text]
             else 
               fields << ["id", node.text]
             end

        when "pbcoreTitle"
              if node.values()[0] == nil 
		fields << ["title_s", node.text]
	      else
		 if node.values()[0] == "Series"
		   fields << ["collection_s", node.text]
		 end
              end
        else 
          fields << ["#{node.name.parameterize}_s", node.text]
      end
    end

    fields.each do |key, value|
      next if value.blank?
      key.gsub!('__', '_')
      solr_doc[key.to_sym] ||= []
      solr_doc[key.to_sym] <<  value.strip
    end

    solr_doc
  end
end
