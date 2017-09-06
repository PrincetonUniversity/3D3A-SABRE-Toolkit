function [decodingMatrix, globalparams] = SABRE_BasicDecoder(maxOrder, posMat, wQList)
%SABRE_BasicDecoder Design a basic (or quadrature) ambisonics decoder.
%   [D, PARAMS] = SABRE_BasicDecoder(L, R) returns basic decoder D and a
%       cell array of decoder parameters PARAMS given a maximum ambisonics
%       order L and a matrix of speaker positions R. By default, the basic
%       decoder is the pseudoinverse of an (L+1)^2-by-P matrix Y of
%       spherical harmonics, where each row of Y corresponds to a different
%       spherical harmonic term and each column corresponds to a different
%       speaker position.
%
%           D = pinv(Y);
%
%       R should be a P-by-3 matrix, where each row is a Cartesian vector,
%       and D will be P-by-(L+1)^2.
%
%   [D, PARAMS] = SABRE_BasicDecoder(L, R, W) computes a quadrature-weighted
%       decoder using the vector W of quadrature weights.
%
%           D = diag(W)*Y';
%
%       W should be a vector of length P.
%
%   See also SABRE_GetDecoder, SABRE_NormalizeDecoder.

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

narginchk(2,3);

% Specify global parameters
globalparams = {'/coeff_scale', 'sn3d'; '/coeff_seq', 'acn'};

% Compute spherical harmonic matrix
Ymatrix = SABRE_SphericalHarmonic(maxOrder, posMat);

if nargin < 3 || isempty(wQList)
    decodingMatrix = pinv(Ymatrix); % P-by-(L + 1)^2
else % Use quadrature weights
    if length(wQList)~=size(posMat,1)
        error('Size mismatch between quadrature weights and grid.');
    end
    
    % Include normalization factor since we use SN3D spherical harmonics
    normVec = zeros((maxOrder + 1)^2,1);
    for l = 0:maxOrder
        for m = -l:l
            acn = l*(l + 1) + m;
            normVec(acn + 1) = 1/(2*l + 1);
        end
    end
    decodingMatrix = diag(wQList)*(Ymatrix.')*diag(1./normVec); % P-by-(L + 1)^2
end

end