require 'spec_helper'
require 'reporting/data_parser'
require 'warehouse/fake_api'

describe DataParser do
  let(:now)              { Time.now.utc }
  let(:start_date)       { Time.parse("2014-08-01") }

  context 'craftsmen' do
    let(:employment_data)  { [{ :start => start_date, :end => now, :position => { :name => "Software Craftsman" }, :person_id => 30 },
                              { :start => start_date, :end => now, :position => { :name => "UX Craftsman" }, :person_id => 29 },
                              { :start => start_date, :end => now, :position => { :name => "Designer" }, :person_id => 31 }] }
    let(:apprenticeships) {
      Warehouse::FakeAPIData.apprenticeships
    }

    context '#student_apprentices_for' do
      it "returns 0 when there are no student apprentices for a given month" do
        parser = DataParser.new([], apprenticeships)

        result = {"Student Apprentices" => 0}

        expect(parser.student_apprentices_for(8, 2014)).to eq(result)
      end

      it "returns the number of student apprentices for a give month" do
        parser = DataParser.new([], apprenticeships)

        result = {"Student Apprentices" => 0}
        expect(parser.student_apprentices_for(9, 2014)).to eq(result)

        result = {"Student Apprentices" => 1}
        expect(parser.student_apprentices_for(12, 2017)).to eq(result)
      end
    end

    context '#all_craftsmen' do
      it 'returns empty list if there are no craftsmen' do
        employment_data = [{ :start => start_date,
                             :end => Time.parse("2014-08-31"),
                             :position => { :name => "Developer" },
                             :person_id => 30 }]

        parser = DataParser.new(employment_data)

        expect(parser.all_craftsmen).to eq({"Software Craftsmen"=>[], "UX Craftsmen"=>[]})
      end

      it 'returns only the craftsmen from the data' do
        parser = DataParser.new(employment_data)

        result = { "Software Craftsmen" => [{ id: 30, start_date: start_date, end_date: now }],
                   "UX Craftsmen" => [{ id: 29, start_date: start_date, end_date: now }] }
        expect(parser.all_craftsmen).to eq result
      end
    end

    context '#active_craftsmen_for' do
      it 'returns 0 if there are no active craftsmen for given month' do
        parser = DataParser.new([])
        expect(parser.active_craftsmen_for(2, 2014)).to eq({"Software Craftsmen" => 0, "UX Craftsmen" => 0})
      end

      it 'returns hash with the count for currently employed craftsmen for a given month' do
        employment_data << { :start => Time.parse("01/01/1990"),
                             :end => Time.parse("01/01/1990"),
                             :position => { :name => "Software Craftsman" },
                             :person_id => 31 }

        parser = DataParser.new(employment_data)

        expect(parser.active_craftsmen_for(start_date.month, start_date.year)).to eq({"Software Craftsmen" => 1, "UX Craftsmen" => 1})
      end

      it 'returns hash with the count for currently employed craftsman' do
        employment_data = [{ :start => Time.parse("2014-08-01"),
                             :end => nil,
                             :position => { :name => "Software Craftsman" },
                             :person_id => 31 }]

        parser = DataParser.new(employment_data)

        expect(parser.active_craftsmen_for(9, 2014)).to eq({"Software Craftsmen" => 1, "UX Craftsmen" => 0})
      end
    end
  end

  context 'residents' do
    let(:employment_data)  { [{ :start => start_date, :end => now, :position => { :name => "Software Resident" }, :person_id => 30 },
                              { :start => start_date, :end => now, :position => { :name => "Not Resident" }, :person_id => 29 },
                              { :start => start_date, :end => now, :position => { :name => "UX Resident" }, :person_id => 31 }] }

    context '#all_residents' do
      it 'returns empty list if there are no residents' do
        employment_data = [{ :start => start_date,
                             :end => Time.parse("2014-08-31"),
                             :position => { :name => "Not Resident" },
                             :person_id => 30 }]

        parser = DataParser.new(employment_data)

        expect(parser.all_residents).to include( "Software Residents" => [], "UX Residents" => [] )
      end

      it 'returns only the residents from the data' do
        parser = DataParser.new(employment_data)

        result = { "Software Residents" => [{ id: 30, start_date: start_date, end_date: now }],
                   "UX Residents" => [{ id: 31, start_date: start_date, end_date: now }] }

        expect(parser.all_residents).to eq result
      end
    end

    context '#active_residents_for' do
      it 'returns 0 if there are no active residents for given month' do
        parser = DataParser.new([])
        expect(parser.active_residents_for(2, 2014)).to eq({"Software Residents" => 0, "UX Residents" => 0})
      end

      it 'returns hash with the count for currently employed residents for a given month' do
        employment_data << { :start => Time.parse("01/01/1990"),
                             :end => Time.parse("01/01/1990"),
                             :position => { :name => "Software Resident" },
                             :person_id => 31 }

        parser = DataParser.new(employment_data)

        expect(parser.active_residents_for(start_date.month, start_date.year)).to eq({"Software Residents" => 1, "UX Residents" => 1})
      end

      it 'returns hash with the count for currently active residents' do
        employment_data = [{ :start => Time.parse("2014-08-01"),
                             :end => nil,
                             :position => { :name => "Software Resident" },
                             :person_id => 31 }]

        parser = DataParser.new(employment_data)

        expect(parser.active_residents_for(9, 2014)).to eq({"Software Residents" => 1, "UX Residents" => 0})
      end
    end

    context '#finishing_on' do
      it 'returns 0 if there are no residents finishing in a given month' do
        parser = DataParser.new([])
        expect(parser.residents_finishing_in(2, 2014)).to eq({ "Software Residents" => 0, "UX Residents" => 0})
      end

      it 'returns hash with the count for residents finishing in a given month' do
        parser = DataParser.new(employment_data)

        expect(parser.residents_finishing_in(now.month, now.year)).to eq({"Software Residents" => 1, "UX Residents" => 1})
      end
    end
  end

  def days_ago(days)
    60 * 60 * 24 * days
  end
end
