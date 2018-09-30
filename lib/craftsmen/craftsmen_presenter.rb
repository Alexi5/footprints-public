require 'craftsmen/skills'

class CraftsmenPresenter
  def initialize(craftsmen)
    @craftsmen = craftsmen
  end

  def seeking_resident_apprentice
    @craftsmen.where("seeking = ?", true).where("skill = ?", Skills.get_key_for_skill("Resident"))
  end

  def seeking_student_apprentice
    @craftsmen.where("seeking = ?", true).where("skill = ?", Skills.get_key_for_skill("Student"))
  end
end
