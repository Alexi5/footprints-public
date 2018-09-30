require 'spec_helpers/craftsman_factory'

require 'craftsmen/craftsmen_interactor'

describe CraftsmenInteractor do
  let(:craftsman) { SpecHelpers::CraftsmanFactory.new.create }
  let(:interactor) { described_class.new(craftsman) }

  it 'updates attributes' do
    interactor.update({name: 'new name', 'skill' =>  2})

    expect(craftsman.name).to eq 'new name'
  end

  it 'ensures that a skill is set' do
    interactor = CraftsmenInteractor.new(craftsman)

    expect { interactor.update({name: 'new name', skill: ''}) }.to raise_error CraftsmenInteractor::InvalidData
  end

  it 'raises error for invalid availability date' do
    interactor = CraftsmenInteractor.new(craftsman)

    expect{ interactor.update(unavailable_until: Date.today) }.to raise_error CraftsmenInteractor::InvalidData
  end
end
