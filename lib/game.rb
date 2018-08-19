require_relative "board.rb"
require_relative "cpu_player.rb"
require_relative "player.rb"

class Game
  attr_accessor :board

  # white: whether or not player 1 wants to be white
  # ai   : whether or not this is an ai game or a 2-player game
  def self.create_game(white = true, ai = false)
    board = Board.create_board
    player_team, other_player_team = (white ? [:white, :black] : [:black, :white])
    # other_player_team = (white ? :black : :white)
    players = [Player.new(player_team)]
    players << (ai ? CPUPlayer.new(other_player_team) : Player.new(other_player_team))
    if(players.first.team == :black)
      new_players = [players.last, players.first]
      players = new_players
    end
    self.new(board, players)
  end

  def initialize(board, players)
    @board = board
    @players = players
  end

  def play_game
    loop do
      @players.each do |player|
        player_team = player.team
        @board.print_board
        unless(board.checkmated?(player_team))
          puts "#{player}'s turn!"
          begin
            puts "Please select a piece!"
            from_algeb = gets.chomp.downcase
            puts "Please select a destination!"
            to_algeb = gets.chomp.downcase
            board.move_piece(from_algeb, to_algeb)
          rescue
            puts "Invalid move"
            retry
          end
        else
          winner = (player.team == :white ? "Black" : "White")
          puts "#{winner} wins!"
          return
        end
      end
    end
  end
end
