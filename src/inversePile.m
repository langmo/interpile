function S = inversePile( S )
% Note: adding 6-6° and relaxing is the same as adding (6-6°)° and
% relaxing, where the latter is the null element. Note that 6-6° is >=3
% everywhere.
% Thus, 2*(6-6°) is >= 6 everywhere.
% Thus, 2*(6-6°)-S is >=3 everywhere, since S is <=3 everywhere.
% Thus, (2*(6-6°)-S)^* = (-S)

S=relaxPile(2*(6*ones(size(S))-relaxPile(6*ones(size(S))))-S);
end

