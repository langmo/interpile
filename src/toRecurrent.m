function S = toRecurrent( S )
while ~isRecurrentPile(S)
    S=relaxPile(S+nullPile(size(S, 1), size(S, 2)));
end
end

