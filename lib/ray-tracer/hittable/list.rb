# frozen_string_literal: true

# Hittable List of Hittable objects
class List < Hittable
  attr_reader :objects

  def initialize(objects = [], **rest)
    super(**rest)
    @objects = objects
  end

  def hit(ray, t_min, t_max)
    list_record = nil
    closest_so_far = t_max
    hit_anything = false

    @objects.each do |object|
      object_hit, object_record = object.hit(ray, t_min, closest_so_far)

      next unless object_hit

      hit_anything = true
      closest_so_far = object_record.t
      list_record = object_record
    end

    [hit_anything, list_record]
  end
end
