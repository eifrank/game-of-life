# frozen_string_literal: true

require 'ruby2d'

set title: 'Game of Life', background: 'white'

SQARE_SIZE = 40
set with: SQARE_SIZE * 16
set height: SQARE_SIZE * 12

class Grid

  def initialize
    @grid = {}
    @playing = false
  end

  def clear
    @grid = {}
  end

  def play_pause
    @playing = !@playing
  end

  def draw_lines
    (Window.width / SQARE_SIZE).times do |x|
      Line.new(
        width: 1,
        color: 'gray',
        y1: 0,
        y2: Window.height,
        x1: x * SQARE_SIZE,
        x2: x * SQARE_SIZE,
      )
    end

    (Window.height / SQARE_SIZE).times do |y|
      Line.new(
        height: 1,
        color: 'gray',
        x1: 0,
        x2: Window.width,
        y1: y * SQARE_SIZE,
        y2: y * SQARE_SIZE,
      )
    end
  end

  def toggle(x,y)
    if @grid.has_key?([x, y])
      @grid.delete([x, y])
    else
      @grid[[x, y]] = true
    end
  end

  def draw_alive_squares
    @grid.keys.each do |x,y|
      Square.new(
        color: 'black',
        x: x * SQARE_SIZE,
        y: y * SQARE_SIZE,
        size: SQARE_SIZE
      )
    end
  end

  def advance_frame
    if @playing
      new_grid = {}

      (Window.width / SQARE_SIZE).times do |x|  
        (Window.height / SQARE_SIZE).times do |y|
          alive = @grid.has_key?([x,y])

          alive_neighbours = [
            @grid.has_key?([x-1, y-1]), # Top Left
            @grid.has_key?([x, y-1]), # Top
            @grid.has_key?([x+1, y-1]), # Top Right
            @grid.has_key?([x+1, y]), # Right
            @grid.has_key?([x+1, y+1]), # Botton Right
            @grid.has_key?([x, y+1]), # Bottom
            @grid.has_key?([x-1, y+1]), # Bottom Left
            @grid.has_key?([x-1, y]), # Left
          ].count(true)

          if ((alive && alive_neighbours.between?(2,3)) ||
            (!alive && alive_neighbours == 3))
            new_grid[[x,y]] = true
          end
        end # end Window.width
      end # end Window.height

      @grid = new_grid
    end
  end
end

grid = Grid.new

update do
  clear
  grid.draw_lines
  grid.draw_alive_squares

  if Window.frames % 20 == 0
    grid.advance_frame
  end
end

on :mouse_down do |event|
  # A mouse event occurred
  grid.toggle(event.x / SQARE_SIZE, event.y / SQARE_SIZE)
end

on :key_down do |event|
  if event.key == 'p'
    grid.play_pause
  end
  
  if event.key == 'c'
    grid.clear
  end
end

show
