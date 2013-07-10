module PostsHelper
  # Finds the break points in a string, given 450px width.  Denotes those breakpoints with '||'
  # @param string text
  #   The string that should be broken.
  def self.find_break_points(text)
    count = position = 0
    text.scan(/./).each do |c|
      count += 1
      position += 1
      if count == 40
        if c == ' '
          text[position] = '||'
        else
          ni = text.index(' ', position - 1)
          ri = text.rindex(' ', position - 1)
          if !ni.nil? && !ri.nil?
            point = [ni, ri].min
          elsif !ri.nil?
            point = ri
          elsif !ni.nil?
            point = ni
          else
            point = 0
          end

          text[point] =  '||'
        end
        count = 1
      end
    end

    text
  end

  # Writes text to an image.
  # @param string path
  #   The path to the image that should have text written on it.
  # @param string meme_text
  #   The text that should be written on the image.
  # @param string meme_position
  #   The position (top or bottom) that the text should be placed on the image.
  def self.image_writer(path, meme_text, meme_position)
  	path = Rails.root.to_s + path
  	path = path.gsub(/\?.*/i, '')

    font_path = Rails.root.to_s + '/DINComp-Medium.ttf'

    the_top_text = the_bottom_text = ''
    if !meme_text.empty?
      if meme_position == 'top'
        the_top_text = meme_text
      elsif meme_position == 'bottom'
        the_bottom_text = meme_text
      end
    end

    # Top text
    if !the_top_text.empty?
      top_text = self.find_break_points(the_top_text)
      top_text = 'Adopt me because...||' + top_text
      top_joined = top_text.split('||')
      top_text = top_joined.join("\n")
      top_height = (top_joined.count * 25) + 10

      # Top text box
      system '''
        convert ''' + path + ''' \
          -strokewidth 0 \
          -fill "rgba( 0, 0, 0 , 0.35 )" \
          -draw "rectangle 0,0 450,''' + top_height.to_s + ''' " \
        ''' + path + '''
      '''

      # Top text
      system '''
        convert ''' + path + ''' \
          -gravity North \
          -font ''' + font_path + ''' \
          -pointsize 25 \
          -size 450x \
          -interline-spacing -13 \
          -fill white \
            -annotate +0-0 "''' + top_text + '''" \
        ''' + path + '''
      '''
    end

    # Bottom text
    if !the_bottom_text.empty?
      bottom_text = self.find_break_points(the_bottom_text)
      bottom_text = 'Adopt me because...||' + bottom_text
      bottom_joined = bottom_text.split('||')
      bottom_text = bottom_joined.join("\n")
      bottom_height = (bottom_joined.count * 25) + 10

      # Bottom text box
      system '''
        convert ''' + path + ''' \
          -strokewidth 0 \
          -fill "rgba( 0, 0, 0 , 0.35 )" \
          -draw "rectangle 450,450 0,''' + (450 - (bottom_height + 6)).to_s + '''" \
        ''' + path + '''
      '''

      # Bottom text
      system '''
        convert ''' + path + ''' \
          -gravity South \
          -font ''' + font_path + ''' \
          -pointsize 25 \
          -size 450x \
          -interline-spacing -13 \
          -fill white \
            -annotate +0-0 "''' + bottom_text + '''" \
        ''' + path + '''
      '''
    end
  end
end
