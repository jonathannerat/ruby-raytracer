# frozen_string_literal: true

require_relative '../hittable'

class Plane < Hittable
  def initialize(origin: Vec3.new, normal: Vec3.new(0,1,0), **rest)
    super(rest[:material])

    @origin = origin
    @normal = normal
  end

  # @param ray [Ray]
  # @param t_min [Float]
  # @param t_max [Float]
  def hit(ray, t_min, t_max)
    return [false] if ray.direction.perpendicular? @normal

    t = (@origin - ray.origin).dot(@normal) / ray.direction.dot(@normal)

    return [false] if t < t_min || t_max < t

    hr = HitRecord.new
    hr.t = t
    hr.point = ray.at t
    hr.material = @material
    hr.set_face_normal(ray, @normal)

    [true, hr]
  end
end
