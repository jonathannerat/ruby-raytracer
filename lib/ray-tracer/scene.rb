# frozen_string_literal: true

require 'yaml'

require_relative 'vec3'
require_relative 'utils'
require_relative 'material'
require_relative 'hittable/sphere'
require_relative 'hittable/list'
require_relative 'hittable/plane'

Output = Struct.new(:width, :height, :spp, :depth)

# Scene camera
class Camera
  attr_accessor :origin, :bl_corner, :horizontal, :vertical, :u, :v, :w, :lens_radius

  # @param from [Vec3]
  # @param to [Vec3]
  # @param vup [Vec3]
  # @param vfov [Float]
  # @param aspect_ratio [Float]
  # @param aperture [Float]
  # @param focus_dist [Float]
  def initialize(from, to, aspect_ratio, vup: Vec3.new(0, 1, 0), vfov: 45, aperture: 0, focus_dist: (from - to).length)
    theta = deg_to_rad(vfov)
    h = Math.tan(theta / 2)
    vp_height = 2 * h
    vp_width = aspect_ratio * vp_height

    @w = (from - to).normalized
    @u = vup.cross(@w).normalized
    @v = @w.cross @u

    @origin = from
    @horizontal = @u * focus_dist * vp_width
    @vertical   = @v * focus_dist * vp_height
    @bl_corner = @origin - (@horizontal + @vertical) / 2 - @w * focus_dist
    @lens_radius = aperture / 2
  end

  def get_ray(s, t)
    rd = Vec3.random_in_unit_disk * @lens_radius
    offset = @u * rd.x + @v * rd.y

    Ray.new(
      @origin + offset,
      @bl_corner + @horizontal * s + @vertical * t - @origin - offset
    )
  end
end

# Represents a scene to be rendered
class Scene
  BG_COLOR = Vec3.new

  def initialize(file)
    file = file ? File.new(file) : STDIN
    scene_hash = YAML.load(file)

    @output = parse_output(scene_hash['output'])
    @camera = parse_camera(scene_hash['camera'])
    @materials = parse_materials(scene_hash['materials'])
    @objects = List.new(parse_objects(scene_hash['objects']))
  end

  def width
    @output.width
  end

  def height
    @output.height
  end

  def spp
    @output.spp
  end

  def pixels
    w = width
    h = height

    h.pred.downto(0).each do |row|
      w.times do |col|
        pixel = Vec3.new
        @output.spp.times do
          u = (col + Random.rand) / (w - 1)
          v = (row + Random.rand) / (h - 1)
          ray = @camera.get_ray(u, v)
          pixel += ray_color(ray)
        end

        yield pixel
      end
    end
  end

  private

  def ray_color(ray, depth = @output.depth)
    return Vec3.new if depth <= 0

    world_hit, world_record = @objects.hit(ray, EPS, Float::INFINITY)

    return BG_COLOR unless world_hit

    material = world_record.material
    emitted = material.emitted
    did_scatter, scattered, attenuation = material.scatter(ray, world_record)

    return emitted unless did_scatter

    emitted + attenuation * ray_color(scattered, depth - 1)
  end

  def parse_output(hash)
    Output.new(
      hash['width'],
      hash['height'],
      hash['spp'],
      hash['depth']
    )
  end

  # Parses a Camera from a Hash
  # @param hash [Hash]
  def parse_camera(hash)
    prepared = prepare_camera_hash(hash)

    Camera.new(
      hash['from'].to_vec,
      hash['to'].to_vec,
      @output.width.to_f / @output.height,
      **prepared
    )
  end

  # @param hash [Hash]
  def prepare_camera_hash(hash)
    camera_hash = {}

    camera_hash[:vup] = hash['vup'].to_vec if hash.key? 'vup'
    camera_hash[:vfov] = hash['vfov'] if hash.key? 'vfov'
    camera_hash[:aperture] = hash['aperture'] if hash.key? 'aperture'
    camera_hash[:focus] = hash['focus'] if hash.key? 'focus'

    camera_hash
  end

  def parse_materials(arr)
    arr.map do |e|
      case e['type']
      when 'lambertian'
        Lambertian.new(e['color'].to_vec)
      when 'light'
        DiffuseLight.new(e['color'].to_vec)
      end
    end
  end

  def parse_objects(arr)
    arr.map do |e|
      props = hash_strings_to_symbols_keys(e)
      props[:material] = @materials[props[:material]]

      case e['type']
      when 'sphere'
        parse_hash_vecs(props, :center)

        Sphere.new(**props)
      when 'plane'
        parse_hash_vecs(props, :origin, :normal)

        Plane.new(**props)
      end
    end
  end

  # Convert a hash with string keys to symbols key
  # @param hash [Hash]
  # @return Hash
  def hash_strings_to_symbols_keys(hash)
    hash.transform_keys(&:to_sym)
  end

  def parse_hash_vecs(hash, *keys)
    keys.each do |k|
      hash[k] = hash[k].to_vec if hash.key?(k)
    end
  end
end
