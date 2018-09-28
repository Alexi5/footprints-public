class Skills
  # A hash of possible skills, where the key is the string name of the skill,
  # and the value is the int representation used to store the value in the db.
  OPTIONS = {
    'Student' => 1,
    'Resident' => 2,
    'Both' => 3,
  # reminder that this is treated
  # as a bit field so next key is 4
  # 'Craftsman' => 4,
  }

  attr_reader :covered_skills

  def initialize(covered_skills)
    @covered_skills = covered_skills
  end

  def self.available_skills
    OPTIONS
  end

  def self.get_key_for(skills)
    skills.map(&:to_i).inject(:|)
  end

  def self.get_key_for_skill(skill)
    OPTIONS[skill.capitalize]
  end

  def cover?(skill)
    normalize(skill) & covered_skills > 0
  end

  private

  # Return the integer key for the given skill.
  def normalize(skills)
    return skills.to_i if skills.to_i > 0

    OPTIONS[skills.capitalize]
  end
end
