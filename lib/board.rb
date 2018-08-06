class Board
  require_relative "piece.rb"

  attr_accessor :board, :left_offset, :algebraic_to_coords, :x_coords, :y_coords

  def self.create_board
    new_board = self.new
    new_board.board = Array.new(8) { Array.new(8) } # row, column

    new_board.x_coords = [*?a..?h]
    p new_board.x_coords
    new_board.y_coords = (1..8).to_a.reverse
    p new_board.y_coords

    # fill the board with appropriate pieces

    # first row: black pieces
    new_board.board[0]  = [Piece.create_piece(:black, :rook),
                           Piece.create_piece(:black, :knight),
                           Piece.create_piece(:black, :bishop),
                           Piece.create_piece(:black, :queen),
                           Piece.create_piece(:black, :king),
                           Piece.create_piece(:black, :bishop),
                           Piece.create_piece(:black, :knight),
                           Piece.create_piece(:black, :rook)]
    # second row: black pawns
    # new_board.board[1]  = Array.new(8) { Piece.create_piece(:black, :pawn) }
    # second-last row: white pawns
    new_board.board[-2] = Array.new(8) { Piece.create_piece(:white, :pawn) }
    # last row: white pieces
    new_board.board[-1] = [Piece.create_piece(:white, :rook),
                           Piece.create_piece(:white, :knight),
                           Piece.create_piece(:white, :bishop),
                           Piece.create_piece(:white, :queen),
                           Piece.create_piece(:white, :king),
                           Piece.create_piece(:white, :bishop),
                           Piece.create_piece(:white, :knight),
                           Piece.create_piece(:white, :rook)]

    new_board.left_offset = 9
    # puts new_board.left_offset

    new_board.algebraic_to_coords = {}
    x = 1
    new_board.board.each_index do |row|
      new_board.board[row].each_index do |col|
        # new_board.board[row][col] = x
        key = "#{new_board.x_coords[col]}#{new_board.y_coords[row]}"
        p key
        new_board.algebraic_to_coords[key] = [row, col]
        x += 1
      end
    end
    p new_board.algebraic_to_coords

    new_board
  end

  def initialize
  end

  def print_board
    square_size = 4
    # @left_offset = 9
    puts
    print_straight_board_line
    puts
    @board.each_with_index do |row, row_index|
      print "".center(@left_offset, " ")
      row.each_with_index do |element, index|
        if index <= 0
          print algebraic_to_coords.key([row_index, index])[-1]
          print " |"
        end
        # print "".center(square_size, " ")
        print element.to_s.center(square_size, " ")

        if(index < row.length - 1)
          print "|"
        else
          print "|\n"
        end
      end

      if(row_index < @board.length - 1)
        print "".center(@left_offset + 2, " ")
        row.each_with_index do |element, index|
          print "".center(square_size, "—")
          print "—" if index == 0 || index == @board.length - 1
          if(index < row.length - 1)
            print "+"
          else
            puts
          end
        end
      end
    end
    print_straight_board_line
    puts
    print "".center(@left_offset + 5, " ")
    @algebraic_to_coords.keys[0..7].each do |key|
      print key.chars.first.ljust(square_size + 1, " ")
    end
    puts "\n\n"
  end


  def print_straight_board_line
    print "".center(@left_offset + 2, " ")
    print "—".center(@board.length*5 + 1, "—")
  end

  # moves a piece to the given location
  def move_piece(from_algeb, to_algeb)

  end

  # TODO determine the valid moves for a piece in a specific position
  # returns a list of algebraic coordinates
  # TODO remove the diagonal moves from pawns unless it's appropriate
  # TODO Castling
  def piece_moves(square_algeb)
    # throw nil error
    row, col = algebraic_to_coords[square_algeb]
    current_piece = board[row][col]
    # goes through each direction, multiplies it by a number
    # to see how *far* we can go
    to_return = []
    current_piece.moves.each do |direction|
      scalar_range = case(current_piece.type)
      when :king, :knight, :pawn
        [1]
      when :bishop, :rook, :queen
        [*1..8]
      end
      scalar_range.each do |scalar|
        current_move = direction.map { |element| element * scalar }
        row_change, col_change = current_move
        new_row, new_col = row + row_change, col + col_change
        # check not out of range
        if(new_row.between?(0, 7) && new_col.between?(0, 7))
          if(board[new_row][new_col].nil? ||
             board[new_row][new_col].team != current_piece.team)
            to_return << algebraic_to_coords.key([new_row, new_col])            
            if(!(board[new_row][new_col].nil?) &&
                 board[new_row][new_col].team != current_piece.team)
              break
            end
          end
        else # stop looking "further" out in this direction
          next
        end
      end
    end
    to_return
  end
end
