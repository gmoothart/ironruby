require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/fixtures/classes'

describe "StringIO#ungetc when passed [char]" do
  before(:each) do
    @io = StringIO.new('1234')
  end

  it "writes the passed char before the current position" do
    @io.pos = 1
    @io.ungetc(?A)
    @io.string.should == 'A234'
  end
  
  it "returns nil" do
    @io.pos = 1
    @io.ungetc(?A).should be_nil
  end

  it "decreases the current position by one" do
    @io.pos = 2
    @io.ungetc(?A)
    @io.pos.should eql(1)
  end

  it "works with read-write" do
    io = StringIO.new("1234", "r+")
    io.pos = 1
    io.ungetc(?A)
    io.string.should == 'A234'
  end
  
  it "modifies the original string" do
    s = '1234'
    io = StringIO.new(s)
    io.pos = 1
    io.ungetc(?A)
    s.should == 'A234'
  end
  
  it "pads with \\000 when the current position is after the end" do
    @io.pos = 15
    @io.ungetc(?A)
    @io.string.should == "1234\000\000\000\000\000\000\000\000\000\000A"
  end

  it "does nothing when at the beginning of self" do
    @io.ungetc(65)
    @io.string.should == '1234'
  end

  it "tries to convert the passed length to an Integer using #to_int" do
    obj = mock("to_int")
    obj.should_receive(:to_int).and_return(?A)

    @io.pos = 1
    @io.ungetc(obj)
    @io.string.should == "A234"
  end

  it "raises a TypeError when the passed length can't be converted to an Integer" do
    lambda { @io.ungetc(Object.new) }.should raise_error(TypeError)
    lambda { @io.ungetc("A") }.should raise_error(TypeError)
  end
end

describe "StringIO#ungetc when self is not readable" do
  it "raises an IOError" do
    io = StringIO.new("test", "w")
    io.pos = 1
    lambda { io.ungetc(?A) }.should raise_error(IOError)
  end

  it "raises an IOError after close_read" do
    io = StringIO.new("test")
    io.pos = 1
    io.close_read
    lambda { io.ungetc(?A) }.should raise_error(IOError)
  end
end

# Note: This is incorrect.
#
# describe "StringIO#ungetc when self is not writable" do
#   ruby_bug "#", "1.8.7.17" do
#     it "raises an IOError" do
#       io = StringIO.new("test", "r")
#       io.pos = 1
#       lambda { io.ungetc(?A) }.should raise_error(IOError)
# 
#       io = StringIO.new("test")
#       io.pos = 1
#       io.close_write
#       lambda { io.ungetc(?A) }.should raise_error(IOError)
#     end
#   end
# end
