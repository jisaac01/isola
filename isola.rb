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
    board.each_with_index do |row, index|
      column = row.index player_id
      puts "|current_position: index, column #{row.inspect}|" if debug
      return [index, column] if column
    end
  end
  
  def active_tiles
    active_tiles = []
    board.each_with_index do |row, index|
      row.each_with_index do |colum, jindex|
        if board[index][jindex] == 0
          active_tiles << [index, jindex]
        end
      end
    end
  end
  
end


def move(board)
  #get current position
  # puts "current_position: #{board.current_position}"
  #get the coordinates of the neighbors
  #sort them in order of openness
  #move to the most open neighbor
  puts "#{get_all_neighbors(board.current_position).first.first} #{get_all_neighbors(board.current_position).first.last}"
end

def get_all_neighbors(position)
  neighbors = []
  neighbors << [position.first - 1, position.last - 1]
  neighbors << [position.first - 1, position.last]
  neighbors << [position.first - 1, position.last + 1]
  neighbors << [position.first, position.last - 1]
  neighbors << [position.first, position.last + 1]
  neighbors << [position.first + 1, position.last - 1]
  neighbors << [position.first + 1, position.last - 1]
  neighbors << [position.first + 1, position.last - 1]
  neighbors
end

def remove_square(board)
  tiles = board.active_tiles.shuffle
  puts "#{tiles.first.first} #{tiles.first.last}"
end

def run
  board = Board.new
  move(board)
  remove_square(board)
  puts "board.player_id: #{board.player_id}"
  puts "board.board: #{board.board.inspect}"
  puts "board.current_position: #{board.current_position(true)}"
end

