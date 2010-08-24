module Enumerable

  # Similar to sort_by, sort_by_str accepts a string containing a SQL-style sort expression.
  #
  # The simplest sort expression is a comma separated list of fields: <tt>'month,day,year'</tt>
  #
  # But can also include optional ASC (ascending) or DESC (descending) order modifiers.
  # For example: <tt>'year DESC, month ASC, day ASC'</tt>
  # If an order modifier is omitted for a field, an ASC sort is assumed.
  #
  # Field values are checked for comparision using a <tt>send</tt>, so any method name can be used.
  def sort_by_str str
    sort_parts = str.split(',').collect { |p| p.split(' ') }
    
    # double-check structure of parsed data
    raise ArgumentError,  "'#{str}' doesn't appear correctly formatted." if sort_parts.empty?
    sort_parts.each { |p| raise ArgumentError, "'#{str}' doesn't appear correctly formatted." if p.length > 2 }
    
    # split into list of fields and sort directions for those fields
    fields          = sort_parts.collect { |p| p.first }
    sort_directions = sort_parts.collect { |p| p.last.upcase == 'DESC' ? :desc : :asc }  # if unspecified assumed to be an ASC sort

    # From here we follow pattern of Schwartzian Transform used in sort_by (http://bit.ly/aPEsNO).
    # This means that rather than doing a sort! directly on self, we cache values to be sorted into an array.
    # So for example, given:
    #  a = Date.today
    #  b = Date.today + 1
    #  [a,b].sort_by_str('year ASC, day DESC')
    #
    # we transform to
    #   [[a, 2010, 22],[b,2010,23]]
    # and then proceed with sort.
    # Following sort, we collect list of first elements to produce final, sorted array.
    # This prevents sort attrs from being called multiple times during sort
    # which could be problematic if sort attr is an expensive calcuation.

    # 1. collect data into intermediate arrays, data element first
    sort_data = collect do |element|
      data = [element]
      fields.each { |f| data << element.send(f) }
      data
    end

    # 2. actually sort the data -- a,b are limited to a[1..-1] so as to exclude first [data] element
    sort_data.sort! do |a,b|
      cmp = 0
      sort_directions.zip(a[1..-1], b[1..-1]) do |field_data|
        direction, a_val, b_val = field_data
        if direction == :desc
          cmp = b_val <=> a_val
        else
          cmp = a_val <=> b_val
        end
        break if cmp != 0
      end

      cmp
    end
    
    # 3. now that data is sorted, reduce back to list of data elements
    sort_data.collect { |element| element.first }
  end
  
end