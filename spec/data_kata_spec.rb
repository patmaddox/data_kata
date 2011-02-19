# File.read("spec/weather.dat")

class WeatherParser
  attr_reader :records, :keys

  def parse(data)
    lines = data.split("\n")
    have_seen_key_line = false
    have_seen_finish_line = false

    lines_to_parse = lines.select do |line|
      have_seen_key_line ||= (line.split[0] == 'Dy')
      have_seen_finish_line ||= (line.split[0] == 'mo')
      have_seen_key_line && !have_seen_finish_line
    end

    @keys = lines_to_parse.shift.split
    lines_to_parse.shift # remove empty line
    # discard non-data line
    @records = lines_to_parse.collect do |line|
      values = line.split
      @keys.zip(values).inject({}) {|hash, pair| hash[pair[0]] = pair[1]; hash }
    end
  end
end

class WeatherData
  attr_reader :day, :temperature_difference

  def initialize(day, high, low)
    @day = day
    @temperature_difference = high - low
  end
end

describe WeatherData do
  let(:data) { WeatherData.new 3, 90, 70 }

  it "knows its day" do
    data.day.should == 3
  end

  it "reports the temperature_difference" do
    data.temperature_difference.should == 20
  end
end

describe "parsing the weather file" do
  it "returns a list of hashes with the data" do
    parser = WeatherParser.new
    parser.parse File.read("spec/weather_simple.dat")
    parser.should have(2).records
    parser.records[0]['Dy'].should == '1'
    parser.records[0]['MxT'].should == '88'
    parser.records[0]['MnT'].should == '59'
    parser.records[1]['Dy'].should == '2'
    parser.records[1]['MxT'].should == '79'
    parser.records[1]['MnT'].should == '63'
  end

  it "knows the keys that were parsed" do
    parser = WeatherParser.new
    parser.parse File.read("spec/weather.dat")
    parser.keys.should == ["Dy", "MxT", "MnT", "AvT", "HDDay", "AvDP", "1HrP", "TPcpn", "WxType", "PDir", "AvSp", "Dir", "MxS", "SkyC", "MxR", "MnR", "AvSLP"]
  end

  it "ignores junk lines" do
    parser = WeatherParser.new
    parser.parse File.read("spec/weather.dat")
    parser.should have(30).records
    parser.records[0]['Dy'].should == '1'
    parser.records[0]['MxT'].should == '88'
    parser.records[0]['MnT'].should == '59'
    parser.records[29]['Dy'].should == '30'
    parser.records[29]['MxT'].should == '90'
    parser.records[29]['MnT'].should == '45'
  end
end

describe WeatherReporter do
  it "prints out the day with the maximum temperature difference" do
    parser = WeatherParser.new
    parser.parse File.read("spec/weather_simple.dat")
    reporter = WeatherReporter.new(parser.records)
    reporter.report.should == "Day 9: 54"
  end
end
