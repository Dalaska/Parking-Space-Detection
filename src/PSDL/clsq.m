function [c,n] = clsq(A,dim);
% Solves constrained linear least squares problem \eqref{clsq} with \texttt{dim} passing \Blue{$d$}
[m,p] = size(A);
if p < dim+1, error ('not enough unknowns'); end;
if m < dim, error ('not enough equations'); end;
m = min (m, p);
R = triu (qr (A)); % First step: orthogonal transformation, see Code~\ref{mc:qrlsqsolve}
[U,S,V] = svd(R(p-dim+1:m,p-dim+1:p)); % Solve \eqref{eq:HRmin2}
n = V(:,dim);
c = -R(1:p-dim,1:p-dim)\R(1:p-dim,p-dim+1:p)*n;
