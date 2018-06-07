function S = dropZoneIrregular(height, width )
if nargin < 1
    width = 15;
    height = 15;
end

S = zeros(height, width);
if mod(width, 2) == 0
    borderV = 3/4*height;
    S(borderV, 1:width/2+1) = S(borderV, 1:width/2+1) + (1:width/2+1);
    S(borderV+1, 1:width/2+1) = S(borderV+1, 1:width/2+1) + 3 * (1:width/2+1);

    S(1:borderV, width/2+1) = S(1:borderV, width/2+1) + (1:borderV)';
    S(1:borderV, end) = S(1:borderV, end) + (width/2+1)*(1:borderV)';

    S(end:-1:borderV+1, width/2+1) = S(end:-1:borderV+1, width/2+1) + 3*(1:height-borderV)';

    S(end:-1:borderV+1, end) = S(end:-1:borderV+1, end) + 3*(width/2+1)*(1:height-borderV)';

    S(borderV, width/2+2:end) = S(borderV, width/2+2:end) + width/2+1;
    S(borderV+1, width/2+2:end) = S(borderV+1, width/2+2:end) + 3*(width/2+1);
else
    borderV = 3/4*(height+1);
    borderH = (width+1)/2;
    S(borderV, 1:borderH) = S(borderV, 1:borderH) + 4*(1:borderH);
    
    S(1:borderV, borderH) = S(1:borderV, borderH) + (1:borderV)';
    S(1:borderV, end) = S(1:borderV, end) + (borderH)*(1:borderV)';
    
    S(end:-1:borderV+1, borderH) = S(end:-1:borderV+1, borderH) + 3*(1:height-borderV)';
    
    S(end:-1:borderV+1, end) = S(end:-1:borderV+1, end) + 3*(borderH)*(1:height-borderV)';
    
    S(borderV, borderH+1:end) = S(borderV, borderH+1:end) + 4*(borderH);

end
end

