class WeatherReporter
  def initialize(weather_data)
    @weather_data = weather_data
  end
  
  def print_max_temperature_difference
    weather_report = @weather_data.sort_by {|d| d.temp_diff }.last
    "#{weather_report.day} - #{weather_report.temp_diff}"
  end
end

class WeatherData
  attr_accessor :day, :min, :max

  def initialize(day, max, min)
    @day = day
    @max = max
    @min = min
  end
  
  def temp_diff
    @max - @min
  end
  
  def ==(other)
    @day == other.day && @min == other.min && @max == other.max
  end
end

class WeatherDataParser
  attr_reader :days

  def initialize(data)
    @data = data
    parse
  end
  
  def parse
    @days = []
    
    in_data_section = false
    @data.each_line do |line|
      in_data_section = true if line.match(/Dy/)
      in_data_section = false if line.match(/mo/)
      
      @days << parse_line(line.strip) if in_data_section && line.strip.match(/^\d/)
    end
  end
  
  def num_days
    @days.size
  end

  def on(day)
    @days[day - 1]
  end

  def parse_line(line)
    WeatherData.new(*line.split(/\s+/)[0..2].map {|d| d.to_i })
  end
end

describe "biggest temperature difference" do
  it "shows the day with the largest temperature difference for a given month" do
    weather_data = WeatherDataParser.new(File.read("spec/weather.dat")).days
    WeatherReporter.new(weather_data).print_max_temperature_difference.should == "9 - 54"
  end
end

describe WeatherDataParser do
  let(:parser) { WeatherDataParser.new(File.read("spec/weather.dat")) }

  it "figures out the number of days in the data" do
    parser.num_days.should == 30
  end

  it "knows the maximum temperature for a given day" do
    parser.on(1).should == WeatherData.new(1, 88, 59)
    parser.on(1).max.should == 88
    parser.on(30).max.should == 90
  end
end

describe  WeatherData do
  
  it "should tell us the temperature difference for a given day" do
    @weather_data = WeatherData.new(1, 88, 59)
    @weather_data.temp_diff.should == 29
  end  
  
end