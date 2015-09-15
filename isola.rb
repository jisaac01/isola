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
    board.each_with_index do |row, index|
      row.each_with_index do |column, jindex|
        rank = valid_neighbors([index, jindex]).size
        @ranks[[index, jindex]] = rank
      end
    end
  end
  
  
  def current_position(debug = false)
    return @current_position if @current_position
    board.each_with_index do |row, index|
      column = row.index player_id
      puts "|current_position: index, column #{row.inspect}|" if debug
      return @current_position = [index, column] if column
    end
  end
  
  def active_tiles(next_position, debug = false)
    active_tiles = []
    board.each_with_index do |row, index|
      row.each_with_index do |val, jindex|
        puts "active_tiles #{index} #{jindex}: #{board[index][jindex]}" if debug
        if val == 0 && next_position != [index, jindex]
          puts "#{val} active" if debug
          active_tiles << [index, jindex]
        end
      end
    end
    active_tiles << current_position
    active_tiles
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
      row <= 6 && row >= 0 &&
      column <= 6 && column >= 0 &&
      board[row][column] != -1
    end
  end
  
  def unnoccupied_neighbors(position)
    valid_neighbors(position).reject do |row, column|
      board[row][column] == opponent_id
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
  tiles = board.active_tiles(@next_position).shuffle
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
