function S = toNonRecurrent( S )

S=3-relaxPile(3-S+nullPile(size(S, 1), size(S, 2)));
end

