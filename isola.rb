class Board
  attr_accessor :board, :player_id, :opponent_id
  def initialize
    self.board = []
    7.times do
      row = gets
      self.board << row.scan(/-?\d+/).map(&:to_i)
    end
    self.player_id = gets.to_i
    self.opponent_id = player_id == 1 ? 2 : 1
    rank_squares
  end
  
  def rank_squares
    return @ranks if @ranks
    @ranks = {}
    each_square do |index, jindex|
      rank = valid_neighbors([index, jindex]).size
      @ranks[[index, jindex]] = rank
    end
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
    
  def all_neighbors(position)
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
  
  def valid_neighbors(position)
    neighbors = all_neighbors(position)
    neighbors.select do |row, column|
      valid_square(row, column)
    end
  end
  
  def unnoccupied_neighbors(position)
    valid_neighbors(position).reject do |row, column|
      board[row][column] == opponent_id
    end
  end
  
  def removal_candidates(next_position, debug=false)
    removal_candidates = []
    each_square do |row, column|
      if valid_square(row, column) &&
        in_the_square_of_influence(row, column) &&
        board[row][column] != opponent_id && 
        next_position != [row, column]
          puts "removal_candidates #{row} #{column}: #{board[row][column]}" if debug  
          removal_candidates << [row, column]
      end      
    end
    removal_candidates
  end
  
  private
  
  def in_the_square_of_influence(row, column)
    row >= (@opponent_position.first - 2) && row <= (@opponent_position.first + 2) &&
    column >= (@opponent_position.last - 2) && column <= (@opponent_position.last + 2)
  end
  
  def valid_square(row, column)
    row <= 6 && row >= 0 &&
    column <= 6 && column >= 0 &&
    board[row][column] != -1
  end
  
  def each_square(&block)
    board.each_with_index do |row, index|
      row.each_with_index do |val, jindex|
        yield index, jindex
      end
    end    
  end
  
  
end


def move(board)
  # get current position
  # get the coordinates o f the neighbors
  unnoccupied_neighbors = board.unnoccupied_neighbors(board.current_position)
  ranks = board.rank_squares
  @ranked_neighbors = unnoccupied_neighbors.sort { |a, b| ranks[b] <=> ranks[a] }
  @next_position = @ranked_neighbors.first
  #sort them in order of openness
  #move to the most open neighbor
  puts "#{@next_position.first} #{@next_position.last}"
end



def remove_square(board)
  tiles = board.removal_candidates(@next_position).shuffle
  puts "#{tiles.first.first} #{tiles.first.last}"
end

def run
  board = Board.new
  move(board)
  remove_square(board)
  puts "ranks: #{board.rank_squares.inspect}"
  puts "ranked_neighbors: #{@ranked_neighbors}"
end

run
