# Ruby implementation of Conway's Game of Life
# run the program as : ruby game_of_life.rb 

require 'rbconfig'
require 'yaml'


class Game

  # def self.windows?
  #   !!(RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
  # end
   
  attr_reader :matrix

  def initialize(rows, cols, seed)
    @matrix = rows.times.map do |y| 
      cols.times.map do |x| 
        Cell.new(self, x, y, rand(seed).to_i.even?)
      end
    end
  end
  
  def play
    generation = 1
    while(true)
      clear
      draw(generation)
      next_life_state
      sleep(1)
      generation +=1
    end
  end
  
  def self.play(rows, cols, seed=Time.now.to_i)
    Game.new(rows, cols, seed).play
  end
  
  def clear
    system('cls') ? window? : system('clear')
  end

  def spinners
    @spinners ||= %w( | / -- \\ )
  end
  

  def draw(generation)
    margin = "\t"
    hline = "=" * (matrix.first.size * 2 + 3)
    spinner = spinners[generation%4]
    [
      "\n"*4,
      hline,
      matrix.map{|row| "= " + row.join(" ") + " =" },
      hline,
      "%2s Generation: #{generation}" % spinner
    ].flatten.each do |line| 
      puts margin + line
    end
  end

  def next_life_state
    matrix.each do |row|
      row.each do |cell|
        cell.next_life_state
      end
    end
  end
  
  def cell_at(x, y)
    matrix.fetch(y){[]}[x]
  end
end

class Cell

  attr_reader :x, :y, :game, :living, :neighbours
  
  def initialize(game, x, y, state)
    @game = game
    @x = x
    @y = y
    @living = state
  end
  
  def die
    @living = false
  end
  
  def reproduce
    @living = true
  end
  
  def alive?
    @living == true
  end

  def dead?
    !alive?
  end
  
  def neighbours
    @neighbours ||= begin
      [
        game.cell_at(x-1, y-1),
        game.cell_at(x, y-1),
        game.cell_at(x+1, y-1),
        game.cell_at(x-1, y),
        game.cell_at(x+1, y),
        game.cell_at(x-1, y+1),
        game.cell_at(x, y+1),
        game.cell_at(x+1, y+1)
      ].compact
    end
  end
  
  def live_neighbours
    neighbours.select(&:alive?)
  end
  
  def under_populated?
    alive? and live_neighbours.size < 2
  end  
  
  def over_populated?
    alive? and live_neighbours.size > 3  
  end  
  
  def can_be_reproduced?
    dead? and live_neighbours.size == 3  
  end

  # Rules for next life state(copied from wiki):
  #   - Any live cell with fewer than two live neighbours dies, as if caused by under-population.
  #   - Any live cell with two or three live neighbours lives on to the next generation.
  #   - Any live cell with more than three live neighbours dies, as if by overcrowding.
  #   - Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
  def next_life_state
    if under_populated? 
      die
    elsif over_populated?
      die
    elsif can_be_reproduced?
      reproduce
    end  
  end
  
  def to_s
    alive? ? "*" : "."
  end
end

if $PROGRAM_NAME == __FILE__
  conf = YAML.load(File.read("config.yaml"))
  rows = conf['rows']
  columns = conf['columns']
  Game.play(rows, columns, Time.now.to_i)
end