require_relative "piece.rb"

class Board
  attr_accessor :board, :left_offset, :algebraic_to_coords, :x_coords, :y_coords

  def self.create_board
    new_board = self.new
    new_board.board = Array.new(8) { Array.new(8) } # row, column

    new_board.x_coords = [*?a..?h]
    # p new_board.x_coords
    new_board.y_coords = (1..8).to_a.reverse
    # p new_board.y_coords

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
    new_board.board[1]  = Array.new(8) { Piece.create_piece(:black, :pawn) }
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
        # p key
        new_board.algebraic_to_coords[key] = [row, col]
        x += 1
      end
    end
    # p new_board.algebraic_to_coords

    new_board
  end

  def initialize
  end

  def board_iterate
    @board.each_with_index do |row, i|
      row.each_with_index do |square, j|
        yield(square, i, j)
      end
    end
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
  # updates move history of the piece
  # TODO don't allow capturing the king
  # TODO don't allow moving to in check or when in check to force getting out
  def move_piece(from_algeb, to_algeb)
    moved = false
    until(moved)
      if(piece_moves(from_algeb).include?(to_algeb))
        row_old, col_old = algebraic_to_coords[from_algeb]
        row_new, col_new = algebraic_to_coords[to_algeb]
        piece = board[row_old][col_old]
        board[row_new][col_new] = board[row_old][col_old]
        board[row_old][col_old] = nil
        piece.move_history << [from_algeb, to_algeb]
        moved = true
        # TODO add a special case for the en passant move
        #      removes the enemy pawn as well
      else
        raise
      end
    end
  end

  # returns a list of algebraic coordinates
  # TODO Castling
  def piece_moves(square_algeb)
    # throw nil error
    row, col = algebraic_to_coords[square_algeb]
    current_piece = board[row][col]
    # goes through each direction, multiplies it by a number
    # to see how *far* we can go
    to_return = []
    # puts current_piece
    potential_moves = current_piece.moves
    case(current_piece.type)
    when(:pawn)
      potential_moves = pawn_moves(square_algeb)
    end
    potential_moves.each do |direction|
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
             square_has_enemy_piece(square_algeb, algebraic_to_coords.key([new_row, new_col])))
            to_return << algebraic_to_coords.key([new_row, new_col])
            if(!board[new_row][new_col].nil? &&
                square_has_enemy_piece(square_algeb, algebraic_to_coords.key([new_row, new_col])))
              break
            end
          else
            break
          end
        else # stop looking "further" out in this direction
          break
        end
      end
    end

    # TODO castling

    to_return
  end

  def square_has_enemy_piece(from_algeb, to_algeb)
    row, col = algebraic_to_coords[from_algeb]
    # p algebraic_to_coords[from_algeb]
    new_row, new_col = algebraic_to_coords[to_algeb]
    # p algebraic_to_coords[to_algeb]
    begin
      return board[row][col].team != board[new_row][new_col].team
    rescue(NoMethodError)
      return false
    end
  end

  # returns raw coordinate changes e.g. [-1, 0]
  # TODO check to make sure the moves are inside the board
  def pawn_moves(square_algeb)
    row, col = algebraic_to_coords[square_algeb]
    pawn = board[row][col]
    potential_moves = []
    if(pawn.type == :pawn)
      case(pawn.team)
      when(:white)
        if((row - 1).between?(0, 7))
          square_one_up = algebraic_to_coords.key([row - 1, col])
          unless(square_has_enemy_piece(square_algeb, square_one_up))
            potential_moves << [-1, 0]
            square_two_up = algebraic_to_coords.key([row - 2, col])
            # if in initial row, can move two up
            if(square_algeb[-1] == "2" &&
                !square_has_enemy_piece(square_algeb, square_two_up))
              potential_moves << [-2, 0]
            end
          end

          if((col + 1).between?(0, 7))
            potential_up_right = algebraic_to_coords.key([row - 1, col + 1])
            if(square_has_enemy_piece(square_algeb, potential_up_right))
              potential_moves << [-1, 1]
            end
          end

          if((col - 1).between?(0, 7))
            potential_up_left  = algebraic_to_coords.key([row - 1, col - 1])
            if(square_has_enemy_piece(square_algeb, potential_up_left))
              potential_moves << [-1, -1]
            end
          end
        end

        # TODO en passant : check pawn.move_history
        # check if the moving pawn is in the right row
        # check if the moved pawn just did the 2 square move
        # add the en passant move

      when(:black)
        if((row + 1).between?(0, 7))
          square_one_down = algebraic_to_coords.key([row + 1, col])
          unless(square_has_enemy_piece(square_algeb, square_one_down))
            potential_moves << [1, 0]
            square_two_down = algebraic_to_coords.key([row + 2, col])
            # if in initial row, can move two down
            if(square_algeb[-1] == "7" &&
                !square_has_enemy_piece(square_algeb, square_two_down))
              potential_moves << [2, 0]
            end
          end

          if((col + 1).between?(0, 7))
            potential_down_right = algebraic_to_coords.key([row + 1, col + 1])
            if(square_has_enemy_piece(square_algeb, potential_down_right))
              potential_moves << [1, 1]
            end
          end

          if((col - 1).between?(0, 7))
            potential_down_left  = algebraic_to_coords.key([row + 1, col - 1])
            if(square_has_enemy_piece(square_algeb, potential_down_left))
              potential_moves << [1, -1]
            end
          end

          # TODO en passant : check pawn.move_history
        end
      end
    end
    potential_moves
  end

  # returns the moves based on the rook in square algeb,
  # returns algebraic coordinates
  # returns a hash of moves
  # { :rook => move,
  #   :king => move }
  # "The king and rook may not have moved,
  # there must not be any obstructing pieces between them,
  # TODO and the King must not move through check in order to complete the move."
  # TODO remove all the moves for the rook, only need the ones for the king
  def castling_moves(square_algeb)
    row, col = algebraic_to_coords[square_algeb]
    piece = board[row][col]
    to_return = {}
    if(piece.type == :rook)
      case(piece.team)
      when(:black)
        king_orginal_row, king_orginal_col = algebraic_to_coords["e8"]
        potential_king = board[king_orginal_row][king_orginal_col]
        # check the given rook
        if(potential_king.type == :king && potential_king.move_history.empty? &&
            piece.move_history.empty?)
          # this is an array of squares horizontally between the given rook and the king
          squares_in_between = []
          start_col, end_col = case(square_algeb)
          when("a8")
            [0, 4]
          when("h8")
            [4, 7]
          end
          [*start_col..end_col].each do |col|
            squares_in_between << board[king_orginal_row][col]
          end

          if(squares_in_between[1..-2].all? { |x| x.nil? })
            to_return[:rook], to_return[:king] = case(square_algeb)
            when("a8")
              ["d8", "c8"]
            when("h8")
              ["g8", "f8"]
            end
          end
        end

      when(:white)
        king_orginal_col, king_orginal_row = algebraic_to_coords["e1"]
        potential_king = board[king_orginal_row][king_orginal_col]
        # check the given rook
        if(potential_king.type == :king && potential_king.move_history.empty? &&
            piece.move_history.empty?)
          # this is an array of squares horizontally between the given rook and the king
          squares_in_between = []
          start_col, end_col = case(square_algeb)
          when("a1")
            [0, 4]
          when("h1")
            [4, 7]
          end
          [*start_col..end_col].each do |col|
            squares_in_between << board[king_orginal_row][col]
          end

          if(squares_in_between[1..-2].all? { |x| x.nil? })
            to_return[:rook], to_return[:king] = case(square_algeb)
            when("a1")
              ["d1", "c1"]
            when("h1")
              ["g1", "f1"]
            end
          end
        end
      end
    else
      return nil
    end
    to_return
  end

  # returns a hash mapping the pieces to their coordinates
  def team_pieces(team)
    to_return = {}
    to_return.compare_by_identity
    board_iterate do |square, row_coord, col_coord|
      if(!square.nil? && square.team == team)
        to_return[square] = algebraic_to_coords.key([row_coord, col_coord])
      end
    end
    to_return
  end

  # returns hash of *white* pieces => algebraic coordinates
  def white_pieces
    team_pieces(:white)
  end

  # returns hash of *black* pieces => algebraic coordinates
  def black_pieces
    team_pieces(:black)
  end

  # returns whether or not the team is in check
  def in_check?(team)
    case(team)
    when(:black)
      # HACK
      king, king_square_algeb = black_pieces.find { |piece, square| piece.type == :king }
      white_pieces.each do |piece, square_algeb|
        if(piece_moves(square_algeb).include?(king_square_algeb))
          return true
        end
      end
    when(:white)
      king, king_square_algeb = white_pieces.find { |piece, square| piece.type == :king }
      black_pieces.each do |piece, square_algeb|
        if(piece_moves(square_algeb).include?(king_square_algeb))
          return true
        end
      end
    end
    return false
  end

  # returns whether or not the team has been checkmated
  def checkmated?(team)
    defending_pieces = case(team)
    when(:white)
      white_pieces
    when(:black)
      black_pieces
    end

    # go through all possible moves of all pieces of the defending team
    # puts defending_pieces.length
    defending_pieces.each do |piece, square_algeb|
      # puts "#{piece}: #{square_algeb}"
      # p piece_moves(square_algeb)
      piece_moves(square_algeb).each do |move|
        test_board = Marshal.load(Marshal.dump(self))
        # if moving the piece were to result in a not check scenario,
        # return false as the defending team is *not* checkmated
        test_board.move_piece(square_algeb, move)
        unless(test_board.in_check?(team))
          return false
        end
      end
    end

    return true
  end
end

class NilClass
  def type
    false
  end
end
