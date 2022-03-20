def rbg_to_hex(rgb)
  return rgb unless rgb.include?('rgb')

  tmp = rgb.tr('rgb()', '').split(',').map(&:to_i)
  "##{tmp.map { |c| c.to_s(16).rjust(2, '0') }.join}"
end
