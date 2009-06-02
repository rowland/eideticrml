require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  describe Support do
    context "parse_measurement" do
      it "should parse integer values" do
        Support::parse_measurement("123").should == [123, :pt]
      end

      it "should parse float values" do
        Support::parse_measurement("123.456").should == [123.456, :pt]
      end

      it "should parse integer values with unit sufix" do
        Support::parse_measurement("123cm").should == [123, :cm]
      end

      it "should parse float values with unit suffix" do
        Support::parse_measurement("123.456cm").should == [123.456, :cm]
      end

      it "should parse values with supplied suffix" do
        Support::parse_measurement("2", :in).should == [2, :in]
      end
    end

    context "parse_measurement_pts" do
      it "should parse integer values" do
        Support::parse_measurement_pts("123").should == 123
      end

      it "should parse float values" do
        Support::parse_measurement_pts("123.456").should == 123.456
      end

      it "should parse integer values with unix suffix" do
        Support::parse_measurement_pts("123cm").should == 3487.05
      end

      it "should parse float values with unit suffix" do
        Support::parse_measurement_pts("123.456cm").should == 3499.9776
      end

      it "should parse values with supplied suffix" do
        Support::parse_measurement_pts("2", :in).should == 144
      end
    end
  end
end
