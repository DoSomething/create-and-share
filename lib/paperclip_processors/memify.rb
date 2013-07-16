module Paperclip
  class Memify < Processor

    def initialize file, options = {}, attachment = nil
      super

      @whiny = options[:whiny].nil? ? true: options[:whiny]
      @format = options[:format]
      @current_format = File.extname(@file.path)
      @basename = File.basename(@file.path, @current_format)
 
      @text = @attachment.instance.meme_text
      @pos = @attachment.instance.meme_position == "top" ? "North" : "South"
      @font = Rails.root.to_s + '/DINComp-Medium.ttf'
    end

    def make
      return @file unless !@text.blank?
      
      dst = Tempfile.new([@basename, @format].compact.join("."))
      dst.binmode

      set_bg = "-background none -bordercolor 'rgba(0, 0, 0, 0.36)' -border 5 -size 440x"
      set_font = "-font #{@font} -fill white -pointsize 24 -gravity Center"
      draw_text = "caption:'Adopt me because...\n#{@text}'"
      composite = "-border 0 #{fromfile} +swap -gravity #{@pos} -composite #{tofile(dst)}"
      
      params = "#{set_bg} #{set_font} #{draw_text} #{composite}"
      Paperclip.run('convert', params)
 
      dst
    end

    def fromfile
      "\"#{ File.expand_path(@file.path) }[0]\""
    end
 
    def tofile(destination)
      "\"#{ File.expand_path(destination.path) }[0]\""
    end

  end
end