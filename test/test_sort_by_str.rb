require 'test_helper'

class SortByStrTest < Test::Unit::TestCase

  context "with valid sort expression" do
    
    setup do
      @red_10 = OpenStruct.new(:color => 'red', :size => 10)
      @blue_10 = OpenStruct.new(:color => 'blue', :size => 10)
      @red_15 = OpenStruct.new(:color => 'red', :size => 15)
      
      @all_data = [@red_10, @blue_10, @red_15]
    end
    
    should "sort correctly on a single-field sort" do
      assert_equal [@blue_10, @red_15], [@red_15, @blue_10].sort_by_str('size')
    end
    
    should "sort correctly on a multi-field sort" do
      assert_equal [@blue_10, @red_10, @red_15], @all_data.sort_by_str('size, color')
    end
    
    should "respect DESC modifier" do
      assert_equal [@red_15, @blue_10, @red_10], @all_data.sort_by_str('size DESC, color')
    end
    
    should "respect ASC modifier" do
      assert_equal [@blue_10, @red_10, @red_15], @all_data.sort_by_str('size ASC, color')
    end
    
    should "sort correctly even if extra spaces are supplied" do
      assert_equal [@blue_10, @red_10, @red_15], @all_data.sort_by_str('size  ASC ,  color ')
    end
    
  end
  
  context "with invalid sort expression" do
    setup do
      @data = [OpenStruct.new(:size => 10), OpenStruct.new(:size => 15)]
    end

    should "raise an ArgumentError if too many tokens are supplied for a field" do
      assert_raises(ArgumentError) { @data.sort('size ASC DESC')}
    end
    
    should "raise an ArgumentError if no fields are supplied" do
      assert_raises(ArgumentError) { @data.sort('') }
    end
    
    should "raise an ArgumentError if no tokens are supplied for a field" do
      assert_raises(ArgumentError) { @data.sort('size ASC, ,size DESC')}
    end
  end

end