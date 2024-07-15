function hex_color_to_rgb --description 'Convert a hex string like "#532555" to its respective RGB decimal values'
  python3 -c 'import sys; hex_color = sys.argv[1].lstrip("#"); rgb = tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4)); print(rgb)' $argv
end
