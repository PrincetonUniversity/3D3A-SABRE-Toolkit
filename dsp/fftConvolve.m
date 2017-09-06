function y = fftConvolve(x,h,METHOD)
%fftConvolve Convolve signals with filters via FFT.
%   y = fftConvolve(x, h) computes filtered signals, y, given input signals
%       x and filter(s) h.

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
if nargin < 3
    METHOD = 'cyclic';
end

[xLen, numCh] = size(x);
[hLen, numIR] = size(h);

switch lower(METHOD)
    case {'pad','linear'}
        FFTLen = 2^(1 + nextpow2(max(xLen,hLen)));
    case {'circular','cyclic'}
        FFTLen = xLen;
        if hLen > xLen
            warning(['Filter length is longer than the input signal,'...
                ' so the filters may be truncated.']);
        end
end

if numIR == 1
    Y = fft(x,FFTLen,1).*(fft(h,FFTLen,1)*ones(1,numCh));
elseif numIR == numCh
    Y = fft(x,FFTLen,1).*fft(h,FFTLen,1);
else
    error('Number of input signals and number of filters do not match.');
end
y = ifft(Y,FFTLen,1,'symmetric');

end