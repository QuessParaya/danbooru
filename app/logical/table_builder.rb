class TableBuilder
  class Column
    attr_reader :attribute, :name, :block, :header_attributes, :body_attributes

    def initialize(attribute = nil, th: {}, td: {}, width: nil, name: nil, &block)
      @attribute = attribute
      @header_attributes = { width: width, **th }
      @body_attributes = td
      @block = block

      @name = name || attribute
      @name = @name.to_s.titleize unless @name.kind_of?(String)
    end

    def value(item, i, j)
      if block.present?
        block.call(item, i, j, self)
        nil
      elsif attribute.kind_of?(Symbol)
        item.send(attribute)
      else
        ""
      end
    end
  end

  attr_reader :columns, :table_attributes, :items

  def initialize(items, **table_attributes)
    @items = items
    @columns = []
    @table_attributes = { class: "striped", **table_attributes }
    yield self if block_given?
  end

  def column(*options, &block)
    @columns << Column.new(*options, &block)
  end

  def all_row_attributes(item, i)
    return {} if !item.is_a?(ApplicationRecord)

    {
      id: "#{item.model_name.singular.dasherize}-#{item.id}",
      **ApplicationController.helpers.data_attributes_for(item, "data", item.html_data_attributes)
    }
  end
end