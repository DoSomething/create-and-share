module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      target = @attachment.instance
      if target.reprocessing?
        target.reprocessed = true
        original_geo = target.image_geometry(:original)
        ratio = original_geo.width / target.crop_dim_w.to_i
        super.unshift(" -crop #{(target.crop_w.to_i * ratio).round}x#{(target.crop_h.to_i * ratio).round}+#{(target.crop_x.to_i * ratio).round}+#{(target.crop_y.to_i * ratio).round}")
      else
        super
      end
    end
  end
end