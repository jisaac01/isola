require 'test/unit'
require_relative 'isola'

class IsolaTest < Test::Unit::TestCase

  def test_board__new
    input_filename = "input_1.txt"
    board = make_board(input_filename)
    assert_equal [6, 3], board.current_position
    
    assert_board_initialization(input_filename, board)
    
  end
  
  def test_board__new__missing_squares
    input_filename = "input_2.txt"
    board = make_board(input_filename)
    assert_equal [5, 2], board.current_position
    
    assert_board_initialization(input_filename, board)    
  end
  
  def test_board__active_tiles
    input_filename = "input_3.txt"
    board = make_board(input_filename)
    
    assert_equal [[0, 3], [1, 4], [5, 0], [5, 1], [5, 3], [5, 4], [5, 5], [5, 6]], 
                 board.active_tiles
  end
  
  def test_board__all_neighbors
    input_filename = "input_3.txt"
    board = make_board(input_filename)
    
    assert_equal [5, 2], board.current_position
    neighbors = board.all_neighbors(board.current_position)
    assert_equal [[4, 1], [4, 2], [4, 3], [5, 1], [5, 3], [6, 1], [6, 1], [6, 1]], neighbors
  end
  
  def test_board__valid_neighbors
    input_filename = "input_3.txt"
    board = make_board(input_filename)
    
    assert_equal [5, 2], board.current_position
    neighbors = board.valid_neighbors(board.current_position)
    assert_equal [[5, 1], [5, 3]], neighbors    
  end
  
  
  private
  
  def assert_board_initialization(input_filename, board)
    File.open(input_filename,"r") do |file|
      file.each_with_index do |line, index|
        break if index > 6
        assert_equal line.split(' ').map(&:to_i), board.board[index]
      end
    end
  end
  
  def make_board(input_filename)
    b = nil
    with_stdin do |command_line|
      File.open(input_filename,"r") do |file|
        file.each do |line|
          command_line.puts line
        end
      end
      
      b = Board.new
    end
    b
  end
    
  def with_stdin
    stdin = $stdin             # remember $stdin
    $stdin, write = IO.pipe    # create pipe assigning its "read end" to $stdin
    yield write                # pass pipe's "write end" to block
  ensure
    write.close                # close pipe
    $stdin = stdin             # restore $stdin
  end
  
end
