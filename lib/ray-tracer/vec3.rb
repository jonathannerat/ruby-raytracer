# frozen_string_literal: true

EPS = 1e-8

# 3D Vectors
class Vec3
  attr_accessor :x, :y, :z

  def initialize(x=0, y=0, z=0)
    @x = x
    @y = y
    @z = z
  end

  def +(other)
    Vec3.new(@x + other.x, @y + other.y, @z + other.z)
  end

  def -(other)
    Vec3.new(@x - other.x, @y - other.y, @z - other.z)
  end

  def -@
    Vec3.new(-@x, -@y, -@z)
  end

  def *(other)
    case other
    when Vec3
      Vec3.new(@x - other.x, @y - other.y, @z - other.z)
    else
      Vec3.new(@x * other, @y * other, @z * other)
    end
  end

  def /(other)
    Vec3.new(@x / other, @y / other, @z / other)
  end

  def ==(other)
    @x == other.x && @y == other.y && @z == other.z
  end

  def dot(other)
    @x * other.x + @y * other.y + @z * other.z
  end

  def cross(other)
    Vec3.new(
      @y * other.z - other.y * @z,
      other.x * @z - @x * other.z,
      @x * other.y - other.x * @y
    )
  end

  def normalized
    self / length
  end

  def length2
    dot self
  end

  def length
    Math.sqrt(length2)
  end

  def near_zero?
    @x.abs < EPS && @y.abs < EPS && @z.abs < EPS
  end

  def perpendicular?(other)
    (dot other).abs < EPS
  end

  def to_s
    "(#{@x}, #{@y}, #{@z})"
  end

  def self.random(min, max)
    fmin = Float(min)
    fmax = Float(max)

    Vec3.new(rand(fmin..fmax), rand(fmin..fmax), rand(fmin..fmax))
  end

  def self.random_in_unit_sphere
    loop do
      v = random(-1, 1)

      next if v.length2 >= 1

      break v
    end
  end

  def self.random_unit_vector
    random_in_unit_sphere.normalized
  end

  def self.random_in_unit_disk
    loop do
      v = random(-1, 1)
      v.z = 0

      next if v.length2 >= 1

      break v
    end
  end
end

def reflect(vec, normal)
  v - normal * (2 * vec.dot(normal))
end

def refract(uv, normal, etai_over_etat)
  cos_theta = [normal.dot(-uv), 1.0].min
  r_out_perp = (uv + normal * cos_theta) * etai_over_etat
  r_out_par = normal * Math.sqrt((1.0 - r_out_perp.length2).abs)

  r_out_perp + r_out_par
end

class Ray
  attr_reader :origin, :direction

  def initialize(origin, direction)
    @origin = origin
    @direction = direction
  end

  def at(t)
    @origin + @direction * t
  end
end

class String
  def to_vec
    components = self[1...-1].split(',').map! { |x| Float(x) }
    Vec3.new(*components)
  end
end

Point = Vec3
Color = Vec3
