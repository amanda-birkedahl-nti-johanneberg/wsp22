# Hjälpfunktioner som inte har någon databas-koppling
module Utils
  # Omvandlar 'rgb(rr,gg,bb)' till motsvarande hex-kod '#XXXXXX'
  # @param [String] rgb
  # @return [String]
  def rbg_to_hex(rgb)
    return rgb unless rgb.include?('rgb')

    tmp = rgb.tr('rgb()', '').split(',').map(&:to_i)
    "##{tmp.map { |c| c.to_s(16).rjust(2, '0') }.join}"
  end

  # omvandlar från int (databas) till rumm-typ
  # @param [Integer] typ
  # @return [String]
  def room_type(typ)
    case typ
    when 0
      'Small'
    when 1
      'Medium'
    when 2
      'Large'
    when 3
      'Suite'
    else
      'Okänd'
    end
  end

  # omvandlar från int (databas) till status
  # @param [Integer] kod
  # @return [String]
  def boknings_status(kod)
    case kod
    when 0
      'Bokad'
    when 1
      'Pågående'
    when 2
      'Slutfört'
    when 3
      'Avbruten'
    when 4
      'Slutfört'
    end
  end
end
