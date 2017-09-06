function [birL, birR, decodingMatrix] = SABRE_NormalizeDecoder(birL, birR, decodingMatrix)
%SABRE_NormalizeDecoder Normalize BIRs and decoder gains.
%   [BL, BR, D] = SABRE_NormalizeDecoder(BL, BR, D) normalizes each pair of
%       BIRs, BL and BR,  on a per-direction basis and compensates each row
%       of the decoding matrix D accordingly. The decoding matrix is then
%       normalized such that the maximum gain throughout the entire matrix
%       is (+/-)1.
%
%   [BL, BR] = SABRE_NormalizeDecoder(BL, BR) performs a single, global
%       normalization over all BIRs.
%
%   See also SABRE_GetDecoder, SABRE_BinauralRenderer.

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

numSpkrs = size(birL,2);
gains = zeros(numSpkrs,1);

% Compute gains
for ii = 1:numSpkrs
    gains(ii) = db2mag(ceil(mag2db(max(max(abs(fft([birL(:,ii) birR(:,ii)],[],1)))))));
end

if nargin < 3 || isempty(decodingMatrix)
    % Global normalization of BIRs only
    birL = birL / max(gains);
    birR = birR / max(gains);
    decodingMatrix = [];
else
    % Normalize BIRs
    birL = birL * diag(1./gains);
    birR = birR * diag(1./gains);

    % Normalize decoding matrix
    decodingMatrix = diag(gains/max(gains)) * decodingMatrix;
    decodingMatrix = decodingMatrix / max(max(abs(decodingMatrix)));
end

end