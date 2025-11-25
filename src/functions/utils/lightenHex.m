function hex_out = lightenHex(hex_in, factor)
    % factor > 1 to light
    rgb = sscanf(hex_in(2:end),'%2x%2x%2x',[1 3]).'/255;
    hsv = rgb2hsv(rgb.');
    hsv(3) = min(1, hsv(3)*factor);
    rgb2 = hsv2rgb(hsv);
    hex_out = sprintf('#%02X%02X%02X', round(rgb2*255));
end
