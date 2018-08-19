class Player
  attr_reader :team

  def initialize(team)
    @team = team
  end

  def to_s
    (@team == :white ? "White" : "Black")
  end
end
