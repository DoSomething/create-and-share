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
      @font = Rails.root.to_s + '/DINComp-Medium.ttf'
    end

    def make
      dst = Tempfile.new([@basename, @format].compact.join("."))
      dst.binmode

      set_bg = "-background none -bordercolor 'rgba(0, 0, 0, 0.36)' -border 5 -size 440x"
      set_font = "-font #{@font} -fill white -pointsize 24 -gravity Center"
      draw_text = "caption:'Adopt me because...\n#{@text}'"
      composite = "-border 0 #{fromfile} +swap -gravity #{@pos} -composite #{tofile(dst)}"
      params = "#{set_bg} #{set_font} #{draw_text} #{composite}"
 
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