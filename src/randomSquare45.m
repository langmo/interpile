function S = randomSquare45(width, N)
    S = zeros(width, width);
    radius = width/sqrt(2);
    for i=1:N
        x = (rand()-0.5)*radius;
        y = (rand()-0.5)*radius;
        
        xx = 1+round((width-1)/2+x*cos(pi/4)-y*sin(pi/4));
        yy = 1+round((width-1)/2+x*sin(pi/4)+y*cos(pi/4));
        S(yy,xx) = S(yy,xx) + 1;
    end
end

