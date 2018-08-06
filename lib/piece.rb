class Piece
  PIECES_SYMBOLS = { # [white, black]
    :king   => {:white => "♔", :black => "♚"},
    :queen  => {:white => "♕", :black => "♛"},
    :rook   => {:white => "♖", :black => "♜"},
    :knight => {:white => "♘", :black => "♞"},
    :bishop => {:white => "♗", :black => "♝"},
    :pawn   => {:white => "♙", :black => "♟"},
  }

  # [up, right]
  # negative means [down, left]
  PIECES_MOVES = {
    :king   => [[ 1, 0],
                [ 1, 1],
                [ 0, 1],
                [-1, 1],
                [-1, 0],
                [-1,-1],
                [ 0,-1],
                [ 1,-1]],
    :queen  => [[ 1, 0],
                [ 1, 1],
                [ 0, 1],
                [-1, 1],
                [-1, 0],
                [-1,-1],
                [ 0,-1],
                [ 1,-1]],
    :rook   => [[ 1, 0],
                [ 0, 1],
                [-1, 0],
                [ 0,-1]],
    :knight => [[ 1,  2],
                [ 2,  1],
                [ 2, -1],
                [ 1, -2],
                [-1, -2],
                [-2, -1],
                [-2,  1],
                [-1,  2]],
    :bishop => [[ 1, 1],
                [-1, 1],
                [-1,-1],
                [ 1,-1]],
    :pawn   => [[ 1, 0],
                [ 1, 1],
                [-1, 1],
                [-1, 0],
                [-1,-1],
                [ 1,-1]]
  }

  attr_accessor :moves
  attr_reader :team, :type, :symbol, :PIECES_MOVES, :PIECES_SYMBOLS
  # attr_reader :white, :black # teams

  def self.create_piece(colour, piece)
    Piece.new(colour, piece, PIECES_SYMBOLS[piece][colour], PIECES_MOVES[piece])
  end

  def initialize(team, type, symbol, moves)
    @team = team
    @type = type
    @symbol = symbol
    @moves = moves
  end

  def to_s
    @symbol
  end
end
