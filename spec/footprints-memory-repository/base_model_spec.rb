require 'spec_helper'
require 'memory_repository/models/base'

class TestBaseModel < MemoryRepository::Base
  data_attributes :name, :hired, :email

  boolean :hired
end

describe TestBaseModel do
  context ".data_attributes" do
    it "creates a getter/setter for each data attr" do
      mock = TestBaseModel.new
      mock.respond_to?(:name).should be_true
      mock.respond_to?(:name=).should be_true
    end
  end

  context "#saves?" do
    it "id is nil if model doesnt save" do
      mock = TestBaseModel.new(:saves => false)
      mock.saves?.should be_false
      mock.id.should be_nil
    end

    it "id is set if model does save" do
      mock = TestBaseModel.new
      mock.saves?.should be_true
      mock.id.should_not be_nil
    end

    it "update attributes returns false if saves is false" do
      mock = TestBaseModel.new(:saves => false)
      mock.saves.should be_false
      mock.update_attributes({:test_attr => "okay"}).should be_false
    end
  end

  context ".boolean" do
    it "returns false for #attribute? if attribute false" do
      mock = TestBaseModel.new(:hired => false)
      mock.hired?.should be_false
    end

    it "true for #attribute? if true" do
      mock = TestBaseModel.new(:hired => true)
      mock.hired?.should be_true
    end
  end

  it "sets attrs based on options" do
    mock = TestBaseModel.new(:name => "Meagan", :email => "meagan@test.com")
    mock.name.should == "Meagan"
    mock.email.should == "meagan@test.com"
  end

  it "returns attributes" do
    mock = TestBaseModel.new(:name => "Meagan", :email => "meagan@test.com")
    mock.attributes.should == {:name => "Meagan", :hired => nil, :email=> "meagan@test.com"}
  end

  it "update_attributes takes a hash of values to change" do
    mock = TestBaseModel.new(:name => "Meagan", :email => "meagan@test.com")
    mock.update_attributes(:name => "Sally", :email => "sally@test.com")
    mock.name.should == "Sally"
    mock.email.should == "sally@test.com"
  end

  it "returns params as string" do
     mock = TestBaseModel.new(:name => "Meagan", :email => "meagan@test.com")
     mock.to_param.should == mock.id.to_s
  end
end
