function S = harmonicMess(height, width )
if nargin < 1
    width = 8;
    height = 8;
end

S = zeros(height, width);

borderV = 3/4*height;
S(borderV, 1:width/2+1) = S(borderV, 1:width/2+1) + (1:width/2+1);
S(borderV+1, 1:width/2+1) = S(borderV+1, 1:width/2+1) + 3 * (1:width/2+1);

S(1:borderV, width/2+1) = S(1:borderV, width/2+1) + (1:borderV)';
S(1:borderV, end) = S(1:borderV, end) + (width/2+1)*(1:borderV)';

S(end:-1:borderV+1, width/2+1) = S(end:-1:borderV+1, width/2+1) + 3*(1:height-borderV)';

S(end:-1:borderV+1, end) = S(end:-1:borderV+1, end) + 3*(width/2+1)*(1:height-borderV)';

S(borderV, width/2+2:end) = S(borderV, width/2+2:end) + width/2+1;
S(borderV+1, width/2+2:end) = S(borderV+1, width/2+2:end) + 3*(width/2+1);
end

