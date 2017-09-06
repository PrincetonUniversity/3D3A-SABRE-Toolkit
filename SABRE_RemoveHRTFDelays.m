function [hL, hR, dL, dR, d0] = SABRE_RemoveHRTFDelays(hL, hR, varargin)
%SABRE_RemoveHRTFDelays Remove delays from HRTF pairs.
%   [HL, HR, DL, DR] = SABRE_RemoveHRTFDelays(HL, HR) computes and removes
%       the time delays, DL and DR, from HRIR pairs, HL and HR. Returns the
%       time-aligned HRIRs and removed delays. DL and DR are given in
%       samples.
%
%   [HL, HR, DL, DR] = SABRE_RemoveHRTFDelays(..., 'upsample', U) upsamples
%       the HRIRs by a factor of U before removing the time delays. The
%       returned time delays are given in samples at the original sample
%       rate, and the HRIRs are downsampled back to the original sample
%       rate before being returned.
%
%   [HL, HR, DL, DR] = SABRE_RemoveHRTFDelays(..., 'threshold', T) uses a
%       threshold of T (which should be between 0 and 1) to determine the
%       onset time delays.
%
%   See also SABRE_InterpolateHRTFs, SABRE_AddHRTFDelays.

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

narginchk(2,6);
if ~isequal(size(hL),size(hR))
    error('Input HRIRs must be the same size.')
end

indx = find(strcmpi(varargin,'upsample'),1,'first');
if indx
    upsampleFlag = true;
    upsampleFactor = varargin{indx+1};
    hL = resample(hL,upsampleFactor,1);
    hR = resample(hR,upsampleFactor,1);
else
    upsampleFlag = false;
end

indx = find(strcmpi(varargin,'threshold'),1,'first');
if indx
    th = varargin{indx+1};
else
    th = [];
end

dL = thresholdIRs(hL, th);
dR = thresholdIRs(hR, th);

d0 = min(min(dL),min(dR));
dL = dL - d0;
dR = dR - d0;

[IRLen, numIR] = size(hL);
for jj = 1:numIR
    gL = delayFilter(-dL(jj),IRLen);
    gR = delayFilter(-dR(jj),IRLen);
    hL(:,jj) = fftConvolve(hL(:,jj),gL,'cyclic'); % essentially a fractional-sample circshift
    hR(:,jj) = fftConvolve(hR(:,jj),gR,'cyclic'); % essentially a fractional-sample circshift
end

if upsampleFlag
    hL = resample(hL,1,upsampleFactor);
    hR = resample(hR,1,upsampleFactor);
    dL = dL/upsampleFactor;
    dR = dR/upsampleFactor;
end

end