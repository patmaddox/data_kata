class WeatherReporter 
  def report_highest(*strings)
    parse_strings(strings.flatten)
    @days.max.report
  end
  
  private
  def parse_line(string)
    string.split
  end
  
  def parse_strings(strings)
    @days = strings.map { |string| Day.new(parse_line(string)) }
  end
end

class Day
  include Comparable
  
  def initialize(array)
    @day, @hi, @lo = array
  end
  
  def difference
    (@hi.to_i - @lo.to_i).abs
  end
  
  def report
    "Day #{@day} - #{difference} degrees"
  end
  
  def <=>(other)
    difference <=> other.difference
  end
end

describe WeatherReporter do
  describe "calculates the difference for its input" do
    it "reports the highest temperature difference in a friendly message" do
      calculator = WeatherReporter.new
      calculator.report_highest("3 77 55", "4 73 57", "6 54 89").should == "Day 6 - 35 degrees"
    end

    it "reports the highest temperature (taking a single string)" do
      string_array = "6 54 89"
      calculator = WeatherReporter.new
      calculator.report_highest(string_array).should == "Day 6 - 35 degrees"
    end
  end
end