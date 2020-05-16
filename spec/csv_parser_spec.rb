RSpec.describe CsvParser do
  let :simple_csv do
    <<~EOF
      foo,bar
      1,2
      3,4
    EOF
  end

  it "parses simple csv files" do
    expect(CsvParser.parse <<~CSV)
      foo,bar
      1,2
      3,4
    CSV
      .to eq [
        ["foo", "bar"],
        ["1", "2"],
        ["3", "4"],
      ]
  end

  it "parses not so simple csv files" do
    expect(CsvParser.parse <<~CSV)
      "
      foo","bar
      "
      "1,1","2
      2"
      "3
      3","4""4"
    CSV
      .to eq [
        ["\nfoo", "bar\n"],
        ["1,1", "2\n2"],
        ["3\n3", "4\"4"],
      ]
  end

  it "allows CRLF line terminators" do
    expect(CsvParser.parse <<~CSV)
      foo,bar\r
      1,2\r
    CSV
      .to eq [
        ["foo", "bar"],
        ["1", "2"],
      ]
  end

  it "allows last line to not have line terminator" do
    expect(CsvParser.parse <<~CSV.chomp)
      foo,bar
      1,2
    CSV
      .to eq [
        ["foo", "bar"],
        ["1", "2"],
      ]

    expect(CsvParser.parse <<~CSV.chomp)
      foo,bar\r
      1,2\r
    CSV
      .to eq [
        ["foo", "bar"],
        ["1", "2"],
      ]
  end

  it "accepts an empty CSV" do
    expect(CsvParser.parse "").to eq []
  end

  it "correctly interprets an empty line" do
    expect(CsvParser.parse "\n").to eq [[""]]
  end

  it "does not accept invalid csv at the end (expects EOF)" do
    # If CsvParser didn't expect an EOF, this wouldn't raise an error. It
    # would just return what it could parse at the beginning.
    expect { CsvParser.parse <<~CSV }
      foo,bar
      1,2
      invalid"invalid
    CSV
      .to raise_error Parsby::Error
  end
end
