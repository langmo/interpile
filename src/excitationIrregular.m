function excitation = excitationIrregular(height, width )
if nargin < 1
    width = 8;
    height = 8;
end

Xt = zeros(height, width);
Xl = Xt;
Xb = Xt;
Xr = Xt;
if mod(width, 2) == 0
    borderT = 3/4*(height);
    borderB = borderT+1;
    borderL = (width)/2;
    borderR = borderL+1;
    
    Xt(1, 1:borderL ) = 1;
    Xt(borderB, 1:borderL ) = 3*(1:borderL);
    Xt(borderB, borderL+1:end ) = 3*(1+borderL);
    
    Xb(end, 1:borderL ) = 1;
    Xb(borderT, 1:borderL ) = (1:borderL);
    Xb(borderT, borderL+1:end ) = (1+borderL);
        
    Xl(:, 1) = 1;
    Xl(1:borderT, borderR) = 0:(borderT-1);
    Xl(end:-1:borderB, borderR) = (1:(height-borderT))*3-1;
    
    Xr(:, borderL) = 1;
    Xr(1:borderT, end) = (borderR)*(1:borderT)';
    Xr(end:-1:borderB, end) = 3*(borderR)*(1:(height-borderT))';
else
    borderV = 3/4*(height+1);
    borderH = (width+1)/2;

    Xt(borderV, 1:borderH) = 4*(1:borderH);
    Xt(borderV, borderH+1:end) = 4*(borderH);


    Xr(1:borderV, borderH) = (1:borderV)';
    Xr(1:borderV, end) = (borderH)*(1:borderV)';
    Xr(end:-1:borderV+1, borderH) = 3*(1:height-borderV)';
    Xr(end:-1:borderV+1, end) = 3*(borderH)*(1:height-borderV)';
end

if nargout == 0
    disp('Xt:');
    disp(Xt);
    disp('Xl:');
    disp(Xl);
    disp('Xb:');
    disp(Xb);
    disp('Xr:');
    disp(Xr);
else
    excitation = struct();
    excitation.Xt = Xt;
    excitation.Xl = Xl;
    excitation.Xb = Xb;
    excitation.Xr = Xr;
end
end

