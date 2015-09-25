#!/usr/bin/env ruby

require 'open3'
# read both filenames
player_program = []
player_program[1] = ARGV.first
player_program[2] = ARGV.last

class Board
  attr_accessor :board, :player_1_position, :player_2_position
  def initialize
    self.board = [
     [0, 0, 0, 1, 0, 0, 0],
     [0, 0, 0, 0, 0, 0, 0], 
     [0, 0, 0, 0, 0, 0, 0],
     [0, 0, 0, 0, 0, 0, 0],
     [0, 0, 0, 0, 0, 0, 0],
     [0, 0, 0, 0, 0, 0, 0],
     [0, 0, 0, 2, 0, 0, 0],
    ]
    self.player_1_position = [0, 3]
    self.player_2_position = [6, 3]
  end
  
  def to_s
    board.each do |row|
      puts " - - - - - - -"
      puts "|#{row.join('|').gsub('0',' ').gsub('-1','X')}|" 
    end
      puts " - - - - - - -"
  end
  
  def has_moves?(player)
    unnoccupied_neighbors(current_position(player)).size > 0
  end
    
  def current_position(player)
    player == 1 ? player_1_position : player_2_position
  end
  
  def set_current_position(player, value)
    if player == 1 
      self.player_1_position = value
    else
      self.player_2_position = value
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
      board[row][column] != 0
    end
  end
  
  def valid_square(row, column)
    row <= 6 && row >= 0 &&
    column <= 6 && column >= 0 &&
    board[row][column] != -1
  end

end

# create the initial board state
board = Board.new
# output the board to stdout
puts board.to_s

current_player = 1
turn = 1
# while the current player is not surrounded
loop do 
  puts "Turn #{turn}, player #{current_player}"

  # run the file with board + player_id as input
  cmd = "ruby #{player_program[current_player]}"
  move = remove = error = nil
  Open3.popen3(cmd) do |stdin, stdout, stderr|
    board.board.each do |row|
      stdin.puts(row.join(' '))
    end
    stdin.puts(current_player)
    stdin.close
    puts "stdout.gets: #{move = stdout.gets}"
    puts "stdout.gets: #{remove = stdout.gets}"
    puts "stderr.gets: #{error = stderr.gets}"
  end
  
  # verify that the output is valid  
  if (move.empty? || remove.empty? || error || move.split(' ').size != 2)
    puts "invalid output #{move}"
    break
  end

  move = move.split(' ').map(&:to_i)
  # verify that the move is valid (on the board, 1 space, etc)
  if board.valid_neighbors(board.current_position(current_player)).include?(move) &&
     board.current_position(current_player) != move
       board.board[board.current_position(current_player).first][board.current_position(current_player).last] = 0
       board.board[move.first][move.last] = current_player
       board.set_current_position(current_player, move)
  else
    puts "board.valid_neighbors(board.current_position(current_player)).include?(move): #{board.valid_neighbors(board.current_position(current_player)).include?(move)}"
    puts "board.valid_neighbors(board.current_position(current_player)): #{board.valid_neighbors(board.current_position(current_player))}"
    puts "move.include?(board.valid_neighbors(board.current_position(current_player))): #{move.include?(board.valid_neighbors(board.current_position(current_player)))}"
    puts "board.current_position(current_player) != move: #{board.current_position(current_player) != move}"
    puts "invalid move #{move}"
    break
  end  
      
  # verify that removal is valid
  remove = remove.split(' ').map(&:to_i)
  # verify that the move is valid (on the board, 1 space, etc)
  if board.current_position(current_player) != remove &&
    board.valid_square(remove.first, remove.last)
      board.board[remove.first][remove.last] = -1
  else
    puts "board.current_position(current_player) != remove: #{board.current_position(current_player) != remove}"
    puts "board.valid_square(remove.first, remove.last): #{board.valid_square(remove.first, remove.last)}"
    puts "invalid remove #{remove}"
    break
  end  
  

  turn = turn + 1
  # output the new board
  puts board.to_s
  current_player = (current_player == 1 ? 2 : 1)
  break if !board.has_moves?(current_player)
end

current_player = (current_player == 1 ? 2 : 1)
puts "Player #{current_player} won!"
