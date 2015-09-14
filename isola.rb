class Board
  attr_accessor :board, :player_id
  def initialize
    self.board = []
    7.times do
      row = gets
      self.board << row.scan(/-?\d+/).map(&:to_i)
    end
    self.player_id = gets.to_i
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
    neighbors.reject do |row, column|
      row > 6 || row < 0 ||
      column > 6 || column < 0 ||
      board[row][column] != 0
    end
  end
  
end


def move(board)
  #get current position
  # puts "current_position: #{board.current_position}"
  #get the coordinates of the neighbors
  #sort them in order of openness
  #move to the most open neighbor
  @next_position = board.valid_neighbors(board.current_position).first
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
end

run
