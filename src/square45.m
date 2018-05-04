function S = square45(width)
S = double(repmat(abs((1:width)-width/2-0.5), width, 1)+repmat(abs((1:width)'-width/2-0.5), 1, width)<=width/2);

end

