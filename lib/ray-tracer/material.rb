# frozen_string_literal: true

require_relative 'vec3'

# Clase base para materiales
class Material
  def scatter(_, _)
    raise NoMethodError
  end
end

# Color difuso lambertiano
class Lambertian < Material
  def initialize(albedo)
    super()
    @albedo = albedo
  end

  # @param ray_in [Ray]
  # @param hit_record [HitRecord]
  def scatter(_, hit_record)
    scatter_dir  = hit_record.normal + Vec3.random_in_unit_sphere

    scatter_dir = hit_record.normal if scatter_dir.near_zero?

    [true, Ray.new(hit_record.point, scatter_dir), @albedo]
  end

  def emitted
    Vec3.new
  end
end

class DiffuseLight < Material
  def initialize(albedo)
    super()
    @albedo = albedo
  end

  def scatter(_, _)
    [false]
  end

  def emitted
    @albedo
  end
end
