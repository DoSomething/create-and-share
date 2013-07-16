module Paperclip
  class Memify < Processor
    include ActionView::Helpers::TextHelper

    def initialize file, options = {}, attachment = nil
      super

      @whiny = options[:whiny].nil? ? true: options[:whiny]
      @format = options[:format]
      @current_format = File.extname(@file.path)
      @basename = File.basename(@file.path, @current_format)
 
      @text = word_wrap(@attachment.instance.meme_text, :line_width => 30)
      @pos = @attachment.instance.meme_position == "top" ? "North" : "South"
      @font = font_path = Rails.root.to_s + '/DINComp-Medium.ttf'
    end

    def make
      dst = Tempfile.new([@basename, @format].compact.join("."))
      dst.binmode
 
      # Background params
      h = bg_height
      y1 = @pos == "North" ? 0 : 450 - h
      y2 = @pos == "North" ? h : 450
      draw_bg = "-fill 'rgba(0, 0, 0, 0.35)' -draw 'rectangle 0,#{y1} 450,#{h}'"
      # Text params
      set_pos = "-gravity #{@pos}"
      set_font = "-font #{@font} -pointsize 24 -size 450x -fill white"
      draw_text = "-annotate 0 #{@text}"
      # Put it all togethers
      params = "#{fromfile} #{draw_bg} #{set_pos} #{set_font} #{draw_text} #{tofile(dst)}"
 
      begin
        success = Paperclip.run('convert', params)
      rescue PaperclipCommandLineError
        raise PaperclipError, "There was an error processing the watermark for #{@basename}" if @whiny
      end
 
      dst
    end

    def fromfile
      "\"#{ File.expand_path(@file.path) }[0]\""
    end
 
    def tofile(destination)
      "\"#{ File.expand_path(destination.path) }[0]\""
    end

    def bg_height
      return 100
    end

  end
end