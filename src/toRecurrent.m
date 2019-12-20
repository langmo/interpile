function S = toRecurrent( S )
S = relaxPile(nullPile(size(S, 1), size(S, 2))+relaxPile(S));
% while ~isRecurrentPile(S)
%     S=relaxPile(S+nullPile(size(S, 1), size(S, 2)));
% end
end

