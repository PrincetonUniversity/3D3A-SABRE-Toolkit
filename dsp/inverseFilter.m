function g = inverseFilter(h, Fs)
%inverseFilter Design regularized inverse filter(s).
%   g = inverseFilter(h, Fs) computes an inverse filter, g, at sampling
%       rate Fs, that is the frequency-domain inverse of the impulse
%       response h. The inverse filter will have the same size as the
%       input. If h is a matrix, an inverse is computed for each column.

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

[IRLen, numIRs] = size(h);
FreqVec = (0:(IRLen-1)).'*Fs/IRLen;

%%TODO%% change these parameters to be input variables
fL1 = 20;
fL2 = 50;
fH1 = 15000;
fH2 = 20000;

band0 = (FreqVec >= fL2) & (FreqVec <= fH1);
band1 = (FreqVec <= fL1) | (FreqVec >= fH2);
bandL = (FreqVec > fL1) & (FreqVec < fL2);
bandH = (FreqVec > fH1) & (FreqVec < fH2);

beta1 = 0.01;
beta0 = 0.0001;
betaL = (beta0 - beta1)*(FreqVec - fL1)/(fL2 - fL1) + beta1;
betaH = (beta1 - beta0)*(FreqVec - fH1)/(fH2 - fH1) + beta0;

beta = zeros(IRLen,1);
beta(band0) = beta0;
beta(band1) = beta1;
beta(bandL) = betaL(bandL);
beta(bandH) = betaH(bandH);

H = fft(h);
g = minimumPhase(ifft(conj(H)./((conj(H).*H)+beta*ones(1,numIRs)),[],1,'symmetric'));

end