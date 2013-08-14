module Paperclip
  class Compress < Processor

    def initialize file, options = {}, attachment = nil
      super

      @whiny = options[:whiny].nil? ? true: options[:whiny]
      @format = options[:format]
      @current_format = File.extname(@file.path)
      @basename = File.basename(@file.path, @current_format)
    end

    def make
      dst = Tempfile.new([@basename, @format].compact.join("."))
      dst.binmode

      Paperclip.run('convert', "-strip -quality 90 #{fromfile} #{tofile(dst)}")
 
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