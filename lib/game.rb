require_relative "board.rb"
require_relative "cpu_player.rb"
require_relative "player.rb"

class Game
  attr_accessor :board

  def self.create_game(ai = false)
    board = Board.create_board
    players = [Player.new]
    players << (ai ? CPUPlayer.new : Player.new)
    self.new(board, players)
  end

  def initialize(board, players)
    @board = board
    @players = players
  end

  def play_game
    @board.print_board
  end
end
