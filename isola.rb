class Intelligence
  
  attr_accessor :game, :board
  
  def initialize(game)
    self.game = game
    self.board = game.board
  end
  
  def move
    # get the coordinates of the neighbors
    unnoccupied_neighbors = board.unnoccupied_neighbors(board.current_position)
    
    # rank the neighbors by their weights
    @ranked_neighbors = unnoccupied_neighbors.sort { |a, b| game.weight(b) <=> game.weight(a) }
    
    # grab any neighbors with the highest weight and get one of them
    next_position = @ranked_neighbors.select { |position| game.weight(position) == game.weight(@ranked_neighbors.first) }.shuffle.first

    "#{next_position.first} #{next_position.last}"
  end

  def remove_square
    # get candidate squares to remove
    removal_candidates = game.removal_candidates(@next_position).sort { |a, b| game.weight(b) <=> game.weight(a) }
    
    # grab any of the candidates with the best chance and get one of them
    top_candidates = removal_candidates.select { |position| game.weight(position) == game.weight(removal_candidates.first) }.shuffle
    
    "#{top_candidates.first.first} #{top_candidates.first.last}"
  end
  
end

# facts about the game state. Number of exits, relative strengths, pieces being considered for removal
class Game
  attr_accessor :board
  
  def initialize(board_state)
    self.board = board_state
    rank_squares
  end

  def weight(position)
    w = rank_squares[position]
    board.neighbors_in_play(position).each do |neighbor|
      w += rank_squares[neighbor] / 8.0
    end
    w
  end
    
  def rank_squares
    return @ranks if @ranks
    @ranks = {}
    board.each_square do |index, jindex|
      rank = board.neighbors_in_play([index, jindex]).size
      @ranks[[index, jindex]] = rank
    end
    @ranks
  end  
  
  def removal_candidates(next_position, debug=false)
    removal_candidates = []
    board.each_square do |row, column|
      if board.square_in_play?(row, column) &&
        in_the_square_of_influence(row, column) &&
        board.board[row][column] != board.opponent_id && 
        next_position != [row, column]
          puts "removal_candidates #{row} #{column}: #{board[row][column]}" if debug  
          removal_candidates << [row, column]
      end      
    end
    removal_candidates
  end
  
  def in_the_square_of_influence(row, column)
    influence = 1
    
    row >= (board.opponent_position.first - influence) && row <= (board.opponent_position.first + influence) &&
    column >= (board.opponent_position.last - influence) && column <= (board.opponent_position.last + influence)
  end
  
end

# facts about the game board; positions, squares, etc
class BoardState
  attr_accessor :board, :player_id, :opponent_id
  def initialize
    self.board = []
    7.times do
      row = gets
      self.board << row.scan(/-?\d+/).map(&:to_i)
    end
    self.player_id = gets.to_i
    self.opponent_id = player_id == 1 ? 2 : 1
  end

  def current_position
    return @current_position if @current_position
    set_positions
    return @current_position
  end
  
  def opponent_position
    return @opponent_position if @opponent_position
    set_positions
    return @opponent_position
  end
  
  def set_positions(debug = false)
    board.each_with_index do |row, index|
      my_column = row.index player_id
      @current_position = [index, my_column] if my_column
      
      opponent_column = row.index opponent_id
      @opponent_position = [index, opponent_column] if opponent_column
    end
  end
    
  def all_possible_neighbors(position)
    neighbors = []
    neighbors << [position.first - 1, position.last - 1]
    neighbors << [position.first - 1, position.last]
    neighbors << [position.first - 1, position.last + 1]
    neighbors << [position.first, position.last - 1]
    neighbors << [position.first, position.last + 1]
    neighbors << [position.first + 1, position.last - 1]
    neighbors << [position.first + 1, position.last]
    neighbors << [position.first + 1, position.last + 1]
    neighbors
  end
  
  def neighbors_in_play(position)
    neighbors = all_possible_neighbors(position)
    neighbors.select do |row, column|
      square_in_play?(row, column)
    end
  end
  
  def unnoccupied_neighbors(position)
    neighbors_in_play(position).reject do |row, column|
      board[row][column] == opponent_id
    end
  end
  
  def each_square(&block)
    board.each_with_index do |row, index|
      row.each_with_index do |val, jindex|
        yield index, jindex
      end
    end    
  end  
  
  def square_in_play?(row, column)
    row <= 6 && row >= 0 &&
    column <= 6 && column >= 0 &&
    board[row][column] != -1
  end
end


def run
  board = BoardState.new
  game = Game.new(board)
  ai = Intelligence.new(game)
  puts ai.move
  puts ai.remove_square
end

run
