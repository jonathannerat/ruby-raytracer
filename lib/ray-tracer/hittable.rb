# frozen_string_literal: true

# Data class to hold information of ray intersections
class HitRecord
  attr_accessor :point, :normal, :t, :front_face, :material

  # Sets both front_face and normal using the internsection data
  # @param ray [Ray]
  # @param outward_normal [Vec3]
  def set_face_normal(ray, outward_normal)
    @front_face = ray.direction.dot(outward_normal).negative?
    @normal = @front_face ? outward_normal : -outward_normal
  end
end

# Model hittable objects
class Hittable
  attr_accessor :ref_point, :material

  def initialize(material = nil)
    @material = material
  end

  def hit(_, _, _)
    raise NoMethodError
  end

  def bounding_box
    raise NoMethodError
  end
end
