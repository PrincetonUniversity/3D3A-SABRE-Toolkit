function eqFilters = SABRE_EqualizationFilters(hrirL, hrirR, posMat, Fs, METHOD)
%SABRE_EqualizationFilters Design equalization filters for HRTFs.
%   EQ = SABRE_EqualizationFilters(HL, HR, R, Fs, TYPE) computes EQ filters
%       of a given TYPE for a set of HRIRs, HL and HR, which are specified
%       at positions R and at sample rate Fs.
%
%   The following types of equalization are available:
%       'none'      - No equalization is applied (default).
%       'front'     - Equalize by the front-most HRTF.
%       'diffuse'   - Equalize by the average HRTF over all directions.
%       'horizontal'- Equalize by the average HRTF over all directions
%                     within +/- 5 deg (elevation) of the horizontal plane.
%
%   See also SABRE_EqualizeHRTFs, SABRE_LoadHRTFs.

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

narginchk(4,5);
FFTLen = 2^(nextpow2(max([size(hrirL,1), size(hrirR,1)])));
if nargin < 5 || strcmpi(METHOD,'none') || isempty(METHOD)
    eqFilters = zeros(FFTLen,2);
    eqFilters(1,:) = 1;
    return
end

HRTFL = fft(hrirL,FFTLen,1);
HRTFR = fft(hrirR,FFTLen,1);

switch lower(METHOD)
    case {'front','frontal'}
        [~,~,R] = cart2sph(posMat(:,1),posMat(:,2),posMat(:,3));
        distVec = sqrt(sum((posMat - ones(size(posMat,1),1)*[mean(R),0,0]).^2,2));
        indx = find(distVec == min(distVec),1,'first');
        avgSpecL = HRTFL(:,indx);
        avgSpecR = HRTFR(:,indx);
    case {'diff','diffuse'}
        Yp = pinv(SABRE_SphericalHarmonic(4, posMat));
        avgSpecL = db2mag((mag2db(abs(HRTFL))*Yp(:,1))/sum(Yp(:,1)));
        avgSpecR = db2mag((mag2db(abs(HRTFR))*Yp(:,1))/sum(Yp(:,1)));
    case {'horiz','horizontal'}
        Yp = pinv(SABRE_SphericalHarmonic(4, posMat));
        [~,ELEV,~] = cart2sph(posMat(:,1),posMat(:,2),posMat(:,3));
        indx = abs(ELEV) < (5*pi/180); % elevations within +/- 5 degrees
        avgSpecL = db2mag((mag2db(abs(HRTFL(:,indx)))*Yp(indx,1))/sum(Yp(indx,1)));
        avgSpecR = db2mag((mag2db(abs(HRTFR(:,indx)))*Yp(indx,1))/sum(Yp(indx,1)));
    otherwise
        warning('Unrecognized equalization method ''%s''; no equalization will be applied.',METHOD);
        eqFilters = zeros(FFTLen,2);
        eqFilters(1,:) = 1;
        return
end

eqFilters = inverseFilter(ifft([avgSpecL, avgSpecR],FFTLen,1,'symmetric'), Fs);

end