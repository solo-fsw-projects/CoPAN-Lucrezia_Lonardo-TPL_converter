function varargout = ifFcn(cond,ifTrue,ifFalse)
% ifFcn Functional inline if.
%
%  Syntax:
%    outVal = ifFcn(cond,ifTrue,ifFalse)
%
%  where if is a boolean that when true, triggers the return of ifTrue, and
%  when false, ifFalse. If either ifTrue or ifFalse are functions, they are
%  evaluated and their output is returned.
%
% Elio Sjak-Shie, 2018
%--------------------------------------------------------------------------

if cond
    [varargout{1:nargout}]  = evalFunc(ifTrue);
else
    [varargout{1:nargout}]  = evalFunc(ifFalse);
end
end

%==========================================================================
function varargout = evalFunc(funcIn)
if isa(funcIn,'function_handle')
    [varargout{1:nargout}] = feval(funcIn);
else
    varargout{1} = funcIn;
end

end

