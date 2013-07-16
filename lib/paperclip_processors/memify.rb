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
      @font = font_path = Rails.root.to_s + '/DINComp-Medium.ttf'
    end

    def make
      dst = Tempfile.new([@basename, @format].compact.join("."))
      dst.binmode
 
      set_pos = "-gravity #{@pos}"
      set_font = "-font #{@font} -pointsize 25"
      set_text = "-annotate 0 '#{@text}'"
      params = "#{fromfile} #{set_pos} #{set_font} #{set_text} #{tofile(dst)}"
 
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

  end
end