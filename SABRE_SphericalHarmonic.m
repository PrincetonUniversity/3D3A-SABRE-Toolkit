function Y = SABRE_SphericalHarmonic(L, R)
%SABRE_SphericalHarmonic Real-valued spherical harmonic function for ambiX.
%   Y = SABRE_SphericalHarmonic(L,R) computes the real-valued, SN3D
%       normalized spherical harmonics, up to order L and for positions R,
%       used in the ambiX plugins. The ambiX spherical harmonic convention
%       is described by Nachbar et al. [1] and Kronlachner [2].
%
%   Note:
%       L must be a scalar.
%       R may be a P-by-3 matrix of directions, where each row is a
%           Cartesian vector.
%       Y will be a (L + 1)^2-by-P matrix.

%   ==============================================================================
%   This file is part of the 3D3A SABRE Toolkit.
%   
%   Joseph G. Tylka <josephgt@princeton.edu>
%   3D Audio and Applied Acoustics (3D3A) Laboratory
%   Princeton University, Princeton, New Jersey 08544, USA
%   
%   MIT License
%   
%   Copyright (c) 2017 Princeton University
%   
%   Permission is hereby granted, free of charge, to any person obtaining a copy
%   of this software and associated documentation files (the "Software"), to deal
%   in the Software without restriction, including without limitation the rights
%   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%   copies of the Software, and to permit persons to whom the Software is
%   furnished to do so, subject to the following conditions:
%   
%   The above copyright notice and this permission notice shall be included in all
%   copies or substantial portions of the Software.
%   
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%   SOFTWARE.
%   ==============================================================================

% Needs at least 2 input arguments
if nargin < 2
    error('Not enough input arguments.');
end

% Compute spherical harmonic matrix
Y = zeros((L + 1)^2, size(R,1));
for l = 0:L
    for m = -l:l
        acn = l*(l + 1) + m;
        Y(acn + 1,:) = ambiXsphericalHarmonic(l, m, R);
    end
end

end

function Y = ambiXsphericalHarmonic(l,m,r)

% Needs at least 3 input arguments
if nargin < 3
    error('Not enough input arguments.');
end

if (l >= 0) && (abs(m) <= l)
    if isvector(r)
        [AZIM,ELEV,~] = cart2sph(r(1),r(2),r(3));
    else
        [AZIM,ELEV,~] = cart2sph(r(:,1),r(:,2),r(:,3));
    end
    
    % Compute normalization term
    Nlm = ambiXnormalization(l,abs(m));
    
    % Compute elevation term
    Pl = legendre(l, sin(ELEV));
    Plm = Pl(abs(m) + 1,:).';
    
    % Compute azimuth term
    if m >= 0
        Tm = cos(m * AZIM);
    else % m < 0
        Tm = sin(abs(m) * AZIM);
    end
    Y = Nlm*Plm.*Tm;
else
    warning('Invalid order and degree.');
    Y = 0;
end

end

function Nlm = ambiXnormalization(l,m)
Nlm = ((-1)^m)*sqrt((2-(~m))/(4*pi)).*sqrt(factorial(l-m)./factorial(l+m));
% Includes Condon-Shortley phase ((-1)^m) to cancel it in the Legendre term.
end