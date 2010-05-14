function pp = ppfit(x,y,xb,n,xs,ys,js)
%PPFIT Fit a piecewise polynomial to noisy data.
%   PP = PPFIT(X,Y,XB) fits a piecewise cubic spline with breaks (or knots)
%   XB to the noisy data (X,Y). X and Y are vectors of the same length.
%   Use PPVAL to evaluate PP.
%
%   PP = PPFIT(X,Y,XB,N) is a generalization to piecewise polynomial 
%   functions of order N (degree N-1), with continuous derivatives up to
%   order N-2. Default is a cubic spline with N = 4.
%
%       N     Function
%       ---------------------------------------------------------
%       2     Piecewise linear and continuous
%       3     Piecewise quadratic with continuous first derivative
%       4     Piecewice cubic with continuous second derivative (default)
%       5     Etc.
%
%   PP = PPFIT(X,Y,XB,N,XS,YS,JS) adds sharp data (exact conditions) to
%   the spline. The array YS specifies values or derivatives for each
%   location in XS. JS specifies the order of the derivative. If all the
%   data in YS is of order zero, JS can be omitted. Derivatives of order
%   N-1 or greater are rejected.
%
%   Example 1:
%       x = cumsum(rand(1,50));
%       y = sin(x/2) + cos(x/4) + 0.05*randn(size(x));
%       xb = x(1:6:end);
%       pp = ppfit(x,y,xb);
%       xx = linspace(min(x),max(x),200);
%       yy = ppval(pp,xx);
%       yb = ppval(pp,xb);
%       plot(x,y,'bo',xx,yy,'r',xb,yb,'r.')
%
%   Example 2:
%       x = linspace(0,2*pi,75);
%       y = sin(x) + 0.07*randn(size(x));
%       xb = [0 2 4.2 6.2];
%       pp = ppfit(x,y,xb,5);
%       xx = linspace(min(x),max(x),200);
%       yy = ppval(pp,xx);
%       yb = ppval(pp,xb);
%       plot(x,y,'bo',xx,yy,'r',xb,yb,'r.')
%
%   Example 3:
%	The exact conditions y(0) = 0, y'(0) = 1 and y'(pi) = -1
%   in Example 2 are set by
%       xs = [0, 0, pi];
%       ys = [0, 1, -1];
%       js = [0, 1, 1];
%       pp = ppfit(x,y,xb,4,xs,ys,js);       
%
%   See also PPVAL, SPLINE, SPLINEFIT

%   Author: jonas.lundgren@saabgroup.com, 2007.

%   2007-02-07  Code cleanup. 
%   2007-02-21  Generalization to piecewise polynomial splines of arbitrary order. 
%   2007-12-11  Exact conditions added. 
%   2008-09-25  Missing pre-allocation added.
%   2008-12-17  New polynomial base eliminating half the unknowns.
%               Short description of the numerical method added.
%   2009-02-24  Update of examples in help.
%   2009-05-06  Name changed from SPFIT to PPFIT.

%--------------------------------------------------------------------------
%   THE NUMERICAL METHOD
%
%   PROBLEM: Minimize |A*u - y| subject to the constraint B*u = b.
%
%   The general solution of the under-determined constraint equation is
%
%       u = B\b + Z*v
%
%   where v is a vector and the matrix Z is a base for the null space of B,
%   i.e. B*Z = 0. Now we must find v to minimize the norm of
%
%       A*u - y = A*Z*v + A*(B\b) - y = G*v - g
%   
%   where G = A*Z and g = y - A*(B\b). The solution is v = G\g and thus
%
%       u = B\b + Z*(G\g)
%
%   In PPFIT Z is found by QR decomposition of B'. In SPLINEFIT, where B
%   has a simple banded structure, a sparse Z is computed. This makes
%   SPLINEFIT more efficient for large problems.
%
%   NOTE: A simple but less efficient alternative for Z is Z = null(B).
%   B\b can be replaced by any other particular solution of the constraint.

if nargin < 2, help ppfit, return, end
if nargin < 3, xb = 0; end
if nargin < 4, n = 4; end
if nargin < 5, xs = []; end
if nargin < 6, ys = zeros(size(xs)); end
if nargin < 7, js = zeros(size(xs)); end

% Check order
if n < 2
    msgid = 'PPFIT:BadOrder'; 
    message = 'The polynomial order N must be at least 2!';
    error(msgid,message)
end

% Check noisy data
x = x(:);
y = y(:);
mx = length(x);             % Number of data points

if length(y) ~= mx
	msgid = 'PPFIT:BadNoisyData';
	message = 'Vectors X and Y must have the same length!';
	error(msgid,message)
end

% Sort data
if any(diff(x) < 0)
    [x,isort] = sort(x);
    y = y(isort);
end

% Check sharp data
xs = xs(:);
ys = ys(:);
js = js(:);
ms = length(xs);

if length(ys) ~= ms
    if length(ys) == 1
        ys = repmat(ys,ms,1);
    else
        msgid = 'PPFIT:BadDataYS';
        message = 'Vectors XS and YS must have the same length!';
        error(msgid,message)
    end
end
if length(js) ~= ms
    if length(js) == 1
        js = repmat(js,ms,1);
    else
        msgid = 'PPFIT:BadDataJS';
        message = 'Vectors XS and JS must have the same length!';
        error(msgid,message)
    end
end

% Reject high order derivatives
xs = xs(js < n-1);
ys = ys(js < n-1);
js = js(js < n-1);

% Unique breaks
xb = xb(:);
if any(diff(xb) <= 0)
    xb = unique(xb);
end

% Ensure at least two breaks
if length(xb) < 2
    xb = [x(1); x(mx)];
    if xb(1) == xb(2)
        xb(2) = xb(1) + 1;
    end
end

% Dimensions
n1 = floor(n/2);            % n = n1 + n2
n2 = ceil(n/2);

nb = length(xb);            % Number of breaks
iu(1:2:nb) = n1;            % Number of unknowns per break
iu(2:2:nb) = n2;
ju = [0, cumsum(iu)];       % Cumulative sum of unknowns
nu = ju(nb+1);              % Number of unknowns

mb = nu - nb - n + 2;       % Number of smoothness conditions
ms = length(xs);            % Number of sharp data points
m = mb + ms;                % Total number of exact conditions

if m == nu
    msgid = 'PPFIT:NoisyDataIgnored';
    message = 'Noisy data ignored. Sharp data determines the spline!';
    warning(msgid,message)
elseif m > nu
    msgid = 'PPFIT:TooMuchSharpData';
    message = 'Overdetermined system. Too much sharp data!';
    error(msgid,message)
end

% Scale data
xb0 = xb;
scale = (nb-1)/(xb(nb)-xb(1));
if scale > 10 || scale < 0.1
    x = scale*x;
    xb = scale*xb;
    xs = scale*xs;
    ys = ys./scale.^js;
end

% Interval lengths
hb = diff(xb);

% Adjust limits
xlim = xb;
xlim(1) = -Inf;
xlim(end) = Inf;

% Bin data
ihist = histc(x,xlim);
ihist = [0; cumsum(ihist(:))];

% Generate polynomial base
[P1,P2] = polybase(n);

% Set up system matrix A (noisy data)
A = spalloc(mx,nu,mx*n);
if m < nu
    jj = 1;
    for k = 1:nb-1          % Loop over intervals
        xk = x(ihist(k)+1:ihist(k+1));
        d = length(xk);
        if d > 0
            ni = iu(k);
            kk = ju(k)+1;
            Ablock = mypolyval(P1,P2,xk-xb(k),hb(k),0,ni);
            A(jj:jj+d-1,kk:kk+n-1) = Ablock;
            jj = jj + d;
        end
    end
end

% Set up smoothness matrix B (exact conditions)
B = spalloc(m,nu,m*(n+n2));
b = zeros(m,1);

jj = 1;
for k = 1:nb-2              % Loop over inner breaks
    ni = iu(k);
    kk = ju(k)+1;
    for j = n-ni:n-2            % Loop over derivatives
        p1 = mypolyval(P1,P2,hb(k),hb(k),j,ni);
        p2 = mypolyval(P1,P2,0,hb(k+1),j,n-ni);
        Brow = [p1, zeros(1,ni)] - [zeros(1,ni), p2];
        B(jj,kk:kk+n+ni-1) = Brow;
        jj = jj + 1;
    end
end

% Add sharp data to matrix B
for i = 1:ms                % Loop over sharp data
    k = find(xs(i) >= xlim,1,'last');
    ni = iu(k);
    kk = ju(k)+1;
    Brow = mypolyval(P1,P2,xs(i)-xb(k),hb(k),js(i),ni);
    B(jj,kk:kk+n-1) = Brow;
    b(jj) = ys(i);
    jj = jj + 1;
end

% Solve: Minimum norm(A*u - y) subject to B*u = b
if  m == 0
    % No constraints (n = 2 and no sharp data)
    u = A\y;
elseif m < nu
    % Compute a base Z for the null space of B (B*Z = 0)
    [Q,R] = qr(full(B'));
    Z = Q(:,m+1:nu);
    G = A*Z;
    % Any sharp data?
    if any(ys)
        u1 = B\b;
        g = y - A*u1;
    else
        u1 = zeros(nu,1);
        g = y;
    end
    % Solve
    u2 = Z*(G\g);
    u = u1 + u2;
else
    % Ignore noisy data
    u = B\b;
end

% Compute polynomial coefficients
coefs = zeros(nb-1,n);
for k = 1:nb-1              % Loop over intervals
    ni = iu(k);
    kk = ju(k)+1;
    uk = u(kk:kk+n-1);
    for j = 0:n-1               % Loop over derivatives
        coefs(k,n-j) = mypolyval(P1,P2,0,hb(k),j,ni)*uk;
        uk = uk/(j+1);
    end
end

% Scale coefficients
if scale > 10 || scale < 0.1
    scalepow = repmat(scale.^(n-1:-1:0), nb-1, 1);
    coefs = scalepow.*coefs;
end

% Make piecewise polynomial
pp.form = 'pp';
pp.breaks = xb0';
pp.coefs = coefs;
pp.pieces = nb-1;
pp.order = n;
pp.dim = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [P1,P2] = polybase(n)
%   POLYBASE computes the polynomial bases P1 and P2 of order N.
%   The rows of P1(:,:,1) are the base polynomials (see POLYVAL) and
%   P1(:,:,J+1) are the derivatives of order J. P1 is the base for odd
%   intervals and P2 for even intervals. If N is even the bases are
%   identical, so P2 is not computed.

n1 = floor(n/2);
n2 = ceil(n/2);
D = diag(n-1:-1:1,1);       % Derivation matrix

x0 = [zeros(n-1,1); 1];
x1 = ones(n,1);

Dx0 = zeros(n,n2);
Dx1 = zeros(n,n2);
for k = 1:n2
    Dx0(:,k) = x0;
    Dx1(:,k) = x1;
    x0 = D*x0;
    x1 = D*x1;
end

P1 = zeros(n,n,n);
P1(:,:,1) = inv([Dx0(:,1:n1), Dx1(:,1:n2)]);        % Polynomial base 1
for k = 2:n
    P1(:,:,k) = P1(:,:,k-1)*D;                      % Derivatives
end

if n2 > n1
    P2 = zeros(n,n,n);
    P2(:,:,1) = inv([Dx0(:,1:n2), Dx1(:,1:n1)]);    % Polinomial base 2
    for k = 2:n
        P2(:,:,k) = P2(:,:,k-1)*D;                  % Derivatives
    end
else
    P2 = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = mypolyval(P1,P2,x,h,jder,ni)
%   MYPOLYVAL evaluates the derivatives (of order JDER) of the polynoms
%   in the base P1 (or P2). X is a vector of relative locations in the
%   interval (the left break is zero), H is the length of the 
%   interval and NI is the number of unknowns associated to the left
%   break. NI determines whether P1 or P2 is the base.

n = size(P1,1);
m = length(x);
y = zeros(m,n);

n1 = floor(n/2);
if ni == n1
    P = P1(:,:,jder+1);
else
    P = P2(:,:,jder+1);
end

a0 = 1/h^jder;
a = a0;

if m == 1 && x == 0
    for k = 1:n
        y(k) = a*P(k,n);
        a = h*a;
        if k == ni, a = a0; end
    end
else
    t = x/h;
    for k = 1:n
        z = a*P(k,jder+1);
        for j = jder+2:n
            z = t.*z + a*P(k,j);
        end
        y(:,k) = z;
        a = h*a;
        if k == ni, a = a0; end
    end
end

