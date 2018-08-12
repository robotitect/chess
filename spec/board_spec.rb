require "board.rb"

describe Board do
  let(:board) { Board.create_board }

  context "pieces_moves" do
    context "bishop" do
      example_group "white" do
        example "start" do
          expect(board.piece_moves("c1")).to match_array([])
        end

        example "pawn d2 => d4" do
          board.move_piece("d2", "d4")
          expect(board.piece_moves("c1")).to match_array(["d2", "e3", "f4",
                                                          "g5", "h6"])
        end

        example "capture" do
          board.move_piece("d2", "d4")
          board.move_piece("g7", "g5")
          # board.print_board
          expect(board.piece_moves("c1")).to match_array(["d2", "e3", "f4",
                                                          "g5"])
        end
      end
    end

    context "king" do
    end

    context "knight" do
    end

    context "pawn" do
      example_group "white" do
        example "start" do
          expect(board.piece_moves("a2")).to match_array(["a3", "a4"])
        end

        example "moved" do
          board.board[6] = Array.new(8) { Piece.create_piece(:white, :pawn) }
          board.move_piece("a2", "a4")
          expect(board.piece_moves("a4")).to match_array(["a5"])
        end

        example "capture" do
          board.move_piece("a7", "a5")
          board.move_piece("a5", "a4")
          board.move_piece("c7", "c5")
          board.move_piece("c5", "c4")
          board.move_piece("b2", "b3")
          expect(board.piece_moves("b3")).to match_array(["b4", "c4", "a4"])
        end

        xexample "en passant" do
        end
      end

      example_group "black" do
        example "capture" do
          board.move_piece("a2", "a4")
          board.move_piece("a4", "a5")
          board.move_piece("a5", "a6")
          expect(board.piece_moves("b7")).to match_array(["b6", "b5", "a6"])
        end
      end
    end

    context "queen" do
    end

    context "rook" do
    end

    context "castling" do
      before do
        board.board[0] = [Piece.create_piece(:black, :rook),
                          nil,
                          nil,
                          nil,
                          Piece.create_piece(:black, :king),
                          nil,
                          nil,
                          Piece.create_piece(:black, :rook)]
        board.board[7] = [Piece.create_piece(:white, :rook),
                          nil,
                          nil,
                          nil,
                          Piece.create_piece(:white, :king),
                          nil,
                          nil,
                          Piece.create_piece(:white, :rook)]
      end

      example "e1" do
        expect(board.piece_moves("e1")).to match_array(["d1", "c1", "f1", "g1"])
      end

      example "e8" do
        expect(board.piece_moves("e8")).to match_array(["d8", "c8", "f8", "g8"])
      end
    end
  end
end
