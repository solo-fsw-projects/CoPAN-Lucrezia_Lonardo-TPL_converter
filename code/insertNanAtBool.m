function Xout = insertNanAtBool(X,bool)
%insertNanAtBool Stretches a vector by NaN insertion.
%
%   Xout = insertNanAtBool(X,bool)
%
%   Stretches a vector X by inserting a single NaN after each sample marked
%   by bool.
%
%   e.g.:  X    = [1 2 3 4 5 6 7];
%          bool = [0 1 1 0 1 0 1];
%
%          Xout = [1 2 NaN 3 NaN 4 5 NaN 6 7 NaN]';
%
%   This is handy for insterting gaps in lines when plotting. Note that the
%   output will always be a single column vector.
%
%    - Elio Sjak-Shie, Jun 2018
%--------------------------------------------------------------------------

% Just return X if it was empty:
if isempty(X)
    Xout = X;
    return
end

assert(numel(X) == numel(bool),...
    'X and bool must have the same number of elements.');
    
if iscategorical(X)
    
    % Insert <undefined> through matrix reshaping:
    randStr       = 'PDT_CAT.78';
    assert(~iscategory(X,randStr),'Categorical error');
    placeHolder   = categorical({randStr});
    Xmat          = [X categorical(NaN(size(X)))]';
    Xmat(2,~bool) = placeHolder;
    Xvec          = Xmat(:);
    Xout          = Xvec(Xvec ~= placeHolder);
    Xout          = removecats(Xout,randStr);
    
else
    
    % Beacuse inf is used as a placeholder, the input cannot contain infs:
    assert(~any(X==inf),'X cannot contain inf.');
    X = X(:);
    
    % Insert NaNs through matrix reshaping:
    Xmat          = [X NaN(size(X))]';
    Xmat(2,~bool) = inf;
    Xvec          = Xmat(:);
    Xout          = Xvec(Xvec ~= inf);
    
end