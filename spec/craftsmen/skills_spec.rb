require 'craftsmen/skills'

describe Skills do
  it 'converts list of given skills into single key' do
    expect(Skills.get_key_for([1, 2])).to eq 3
    expect(Skills.get_key_for(["1", "2"])).to eq 3
    expect(Skills.get_key_for([1, 2, 4])).to eq 7
  end

  it 'provides a key for a skill' do
    expect(Skills.get_key_for_skill('Resident')).to eq 2
  end

  context 'all skills' do
    let(:maximum_skill_key)  { Skills.available_skills.values.max }
    let(:all_skills) { Skills.new(maximum_skill_key) }

    Skills.available_skills.each do |skill, key|
      it "covers skill '#{skill}'" do
        expect(all_skills.cover?(key)).to be true
      end
    end
  end

  context 'single skill' do
    let(:skill) { Skills.new(1) }

    it 'covers only one skill' do
      expect(skill.cover?(1)).to be true
    end

    it 'doesn\'t cover another skill' do
      expect(skill.cover?(2)).to be false
    end
  end

  context 'legacy data conversions' do
    it 'can answer if string skills are covered' do
      skills = Skills.new(1)

      expect(skills.cover?('Student')).to be true
      expect(skills.cover?('Resident')).to be false
    end

    it 'compares case insensitive' do
      skills = Skills.new(1)

      expect(skills.cover?('sTuDeNt')).to be true
    end
  end
end
