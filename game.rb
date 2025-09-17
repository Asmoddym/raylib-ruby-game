require 'raylib'

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

# Block class represents a destructible block in the game
class Block
  attr_reader :image, :texture, :position
  attr_accessor :destroyed

  def initialize(x:, y:)
    @image = Raylib.load_image("resources/block.png")
    @texture = Raylib.load_texture_from_image(image)
    @position = Raylib::Vector2.create(x, y)
    @destroyed = false
  end

  def draw
    Raylib.draw_texture(texture, position.x.to_i, position.y.to_i, Raylib::WHITE)
  end

  def displayable?
    !@destroyed
  end
end

# Bar class represents the player's paddle
class Bar
  attr_reader :image, :texture, :position

  def initialize
    @image = Raylib.load_image("resources/bar.png")
    @texture = Raylib.load_texture_from_image(image)
    @position = Raylib::Vector2.create(SCREEN_WIDTH / 2 + texture.width / 2, 420)
  end

  def draw
    Raylib.draw_texture(texture, position.x.to_i, position.y.to_i, Raylib::WHITE)
  end
end

# Ball class represents the ball in the game
class Ball
  attr_reader :image, :texture, :position

  def initialize(bar)
    @image = Raylib.load_image("resources/ball.png")
    @texture = Raylib.load_texture_from_image(image)
    @position = Raylib::Vector2.create(bar.position.x + bar.texture.width / 2 - texture.width / 2, 420 - texture.height)
  end

  def draw
    Raylib.draw_texture(texture, position.x.to_i, position.y.to_i, Raylib::WHITE)
  end
end

# Check for collisions between the ball and blocks
def check_collisions(ball, blocks)
  blocks.select(&:displayable?).each do |block|
    ball_rect = Raylib::Rectangle.create(ball.position.x, ball.position.y, ball.texture.width, ball.texture.height)
    block_rect = Raylib::Rectangle.create(block.position.x, block.position.y, block.texture.width, block.texture.height)

    if Raylib.check_collision_recs(ball_rect, block_rect)
      block.destroyed = true

      return
    end
  end
end


#######


Raylib.init_window(SCREEN_WIDTH, SCREEN_HEIGHT, 'Hello, Raylib!')
Raylib.set_target_fps(60)

ball = nil
bar = Bar.new
blocks = [
  Block.new(x: 50, y: 100),
  Block.new(x: 200, y: 50),
  Block.new(x: 400, y: 200)
]

until Raylib.window_should_close
  Raylib.begin_drawing
  Raylib.clear_background(Raylib::BLACK)

  if Raylib.is_key_pressed(Raylib::KEY_SPACE) && ball.nil?
    ball = Ball.new(bar)
  elsif Raylib.is_key_down(Raylib::KEY_RIGHT)
    bar.position.x += 5
  elsif Raylib.is_key_down(Raylib::KEY_LEFT)
    bar.position.x -= 5
  end

  bar.draw
  blocks.select(&:displayable?).each(&:draw)

  if ball
    ball.draw
    check_collisions(ball, blocks)

    ball.position.y -= 5
    if ball.position.y < 0
      ball = nil
    end

  end

  Raylib.end_drawing
end

# You should unload textures and images here to free memory
Raylib.close_window
