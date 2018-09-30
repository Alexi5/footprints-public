require 'spec_helper'
require 'reporting/real_data_parser'

describe RealDataParser do
  let(:now)              { Time.now.utc }
  let(:start_date)       { Time.parse("2014-08-01") }
  let(:craftsmen_mock_data) { [
      Craftsman.new(id: 1, name: "Tom Johannsen", status: nil, employment_id: 0, uid: nil, email: "tom.johannsen@abcinc.com", location: "Chicago", archived: false, position: nil, seeking: true, skill: 2, has_apprentice: false, start_date: Date.parse("2018-08-10"), end_date: nil,unavailable_until: nil),
      Craftsman.new(id: 2, name: "Douglas Kles", status: nil, employment_id: 1, uid: nil, email: "douglas.kles@abcinc.com", location: "Chicago", archived: false, position: nil, seeking: true, skill: 2, has_apprentice: false, start_date: Date.parse("2018-08-10"), end_date: nil,unavailable_until:nil),
      Craftsman.new(id: 3, name: "Alan Abernathy", status: nil, employment_id: 2, uid: nil, email: "alan.abernathy@abcinc.com", location: "Chicago", archived: false, position: nil, seeking: true, skill: 1, has_apprentice: false, start_date: Date.parse("2018-08-10"), end_date: nil, unavailable_until: nil),
    ]}

    let(:apprentice_mock_data) { [
      Apprentice.new(id: 2, created_at: "2018-08-10 21:20:16", updated_at: "2018-08-10 21:20:16", name: "Art Blakey", applied_on: nil, email: "art.blakey@gmail.com", hired: nil, location: "Chicago", archived: nil, position: "developer", start_date: Date.parse("2018-08-10"), end_date: Date.parse("2018-11-11"), mentor: nil),

      Apprentice.new(id: 3, created_at: "2018-08-10 21:21:29", updated_at: "2018-08-10 21:21:29", name: "Dave Brubeck", applied_on: nil, email: "dave.brubeck@gmail.com", hired: nil,location: "Chicago", archived: nil, position: "developer", start_date: Date.parse("2018-08-10"), end_date: Date.parse("2018-11-11"), mentor: "Charlie Batch"),

      Apprentice.new(id: 4, created_at: "2018-08-10 21:22:24", updated_at: "2018-08-10 21:22:24", name: "Bill Evans", applied_on: nil, email: "bill.evans@gmail.com", hired: nil, location: "Los Angeles", archived: nil, position: "designer", start_date: Date.parse("2018-08-10"), end_date: Date.parse("2018-11-11"), mentor: "Russell Baker (London Director)")
    ]}

  context 'crafters' do

    context '#all_crafters' do
      it 'returns empty list if there are no crafters' do
        parser = RealDataParser.new([], [])

        expect(parser.all_crafters).to eq({"Software Crafters"=>[], "UX Crafters"=>[]})
      end

      xit 'returns only the craftsmen from the data' do
        parser = RealDataParser.new(craftsmen_mock_data, [])

        expect(parser.all_crafters).to eq(
          {"Software Crafters" => craftsmen_mock_data[0,2], "UX Crafters" => craftsmen_mock_data[2,1]}
        )
      end
    end

    context '#active_crafters_for(month, year)' do
      xit 'returns a hash with 0 if there are no active crafters for given month' do
        parser = RealDataParser.new(craftsmen_mock_data,[])

        expect(parser.active_crafters_for(2, 2014)).to eq({"Software Crafters" => 0, "UX Crafters" => 0})
      end

      xit 'returns hash with the counts for currently employed crafters for a given month' do
        parser = RealDataParser.new(craftsmen_mock_data, [])

        expect(parser.active_crafters_for(9, 2018)).to eq({"Software Crafters" => 2, "UX Crafters" => 1})
      end
    end
  end

  context 'apprentices' do
    context '#software_apprentices_for(month, year)' do
      xit 'returns 0 when there are no apprentices for the given month' do
        parser = RealDataParser.new(craftsmen_mock_data, apprentice_mock_data)

        result = {"Software Apprentices" => 0}

        expect(parser.software_apprentices_for(8, 2014)).to eq(result)
      end

      xit "returns the number of software apprentices for a given month" do
        parser = RealDataParser.new(craftsmen_mock_data, apprentice_mock_data)

        result = {"Software Apprentices" => 2}
        expect(parser.software_apprentices_for(9, 2018)).to eq(result)
      end
    end

    context "#all_apprentices" do
      it 'returns empty hashes if there are no apprentices' do
        parser = RealDataParser.new([],[])

        expect(parser.all_apprentices).to eq("Software Apprentices" => [], "UX Apprentices" => [] )
      end

      it 'returns only the apprentices from the data' do
        parser = RealDataParser.new([], apprentice_mock_data)

        expect(parser.all_apprentices).to eq(
          {"Software Apprentices" => apprentice_mock_data[0,2], "UX Apprentices" => apprentice_mock_data[2,1]})
      end
    end

    context '#active_apprentices_for(month, year)' do
      it 'returns hash of 0s if there are no active apprentices for given month' do
        parser = RealDataParser.new([], apprentice_mock_data)

        expect(parser.active_apprentices_for(7, 2018)).to eq(
          {"Software Apprentices" => 0, "UX Apprentices" => 0}
        )
      end

      it 'returns hash with the count for active apprentices for a given month' do

        parser = RealDataParser.new([], apprentice_mock_data)

        expect(parser.active_apprentices_for(9, 2018)).to eq({"Software Apprentices" => 2, "UX Apprentices" => 1})
      end
    end

    context '#apprentices_finishing_in(month,year)' do
      it 'returns 0 if there are no apprentices finishing in the given month' do
        parser = RealDataParser.new([],[])
        expect(parser.apprentices_finishing_in(11,2018)).to eq( {"Software Apprentices" => 0, "UX Apprentices" => 0})
      end

      it 'returns all apprentices finishing in the given month' do
        parser = RealDataParser.new([], apprentice_mock_data)
        expect(parser.apprentices_finishing_in(11, 2018)).to eq( {"Software Apprentices" => 2, "UX Apprentices" => 1})
      end
    end
  end
end
