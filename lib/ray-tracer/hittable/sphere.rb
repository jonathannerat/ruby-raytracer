# frozen_string_literal: true

require_relative '../hittable'

# Sphere object
class Sphere < Hittable
  attr_accessor :center, :radius

  def initialize(center: Vec3.new, radius: 1, **rest)
    super(rest[:material])
    @center = center
    @radius = radius
  end

  # @param ray [Ray]
  # @param t_min [Float]
  # @param t_max [Float]
  def hit(ray, t_min, t_max)
    oc = ray.origin - @center
    a = ray.direction.length2
    hb = oc.dot ray.direction
    c = oc.length2 - radius.abs2

    discriminant = hb * hb - a * c

    return [false] if discriminant.negative?

    sqrtd = Math.sqrt(discriminant)

    # Find the nearest root that lies in the acceptable range.
    root = (-hb - sqrtd) / a

    if root < t_min || t_max < root
      root = (-hb + sqrtd) / a

      return [false] if root < t_min || t_max < root
    end

    [true, record_from_ray_intersection(ray, root)]
  end

  private

  def record_from_ray_intersection(ray, t)
    record = HitRecord.new

    record.t = t
    record.point = ray.at t
    outward_normal = (record.point - @center) / @radius
    record.set_face_normal(ray, outward_normal)
    record.material = @material

    record
  end
end
