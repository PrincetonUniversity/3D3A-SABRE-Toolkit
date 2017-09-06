function [hrirL, hrirR, desiredGrid] = SABRE_InterpolateHRTFs(hrirDataL, hrirDataR, measuredGrid, varargin)
%SABRE_InterpolateHRTFs Interpolate measured HRTFs to a desired grid.
%   [XL, XR, RD] = SABRE_InterpolateHRTFs(HL, HR, RM, RD) returns HRIRs XL
%       and XR for the desired positions RD, given input HRIRs HL and HR
%       that are measured at positions RM. The returned HRIRs are the
%       'nearest neighbors,' computed by finding the nearest point on the
%       measured grid to each point on the desired grid and returning the
%       corresponding measured HRIRs.
%
%   [XL, XR, RD] = SABRE_InterpolateHRTFs(HL, HR, RM, RD, METHOD) uses one
%       of the following interpolation methods:
%           'nearest'   - Nearest neighbor interpolation (default)
%           'natural'   - Natural neighbor interpolation
%           'linear'    - Linear interpolation
%           'sh'        - Spherical-harmonic interpolation
%
%   [XL, XR, RD] = SABRE_InterpolateHRTFs(HL, HR, RM, RD, METHOD, DOMAIN)
%       performs interpolation in either of the following domains:
%           'time'      - Averages time-aligned impulse responses (default)
%           'frequency' - Averages magnitude spectra in dB and computes
%                         minimum-phase impulse responses
%
%   [XL, XR, RD] = SABRE_InterpolateHRTFs(HL, HR, RM, RD, METHOD, DOMAIN, THRESHOLD)
%       limits interpolation to only those desired grid positions that are
%       at least THRESHOLD degrees away from the nearest measurement
%       position. Within the THRESHOLD, nearest-neighbor interpolation is
%       used.
%
%   [XL, XR, RD] = SABRE_InterpolateHRTFs(HL, HR, RM, CONFIG) interpolates
%       the measured HRIRs using specified CONFIG settings.
%
%   See also SABRE_LoadHRTFs, SABRE_RemoveHRTFDelays, SABRE_AddHRTFDelays.

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

narginchk(4,7);
if nargin == 4 && isstruct(varargin{1})
    config = varargin{1};
else
    if nargin >= 4
        config.interpolation_grid = varargin{1};
    end
    if nargin >= 5
        config.interpolation_method = varargin{2};
    end
    if nargin >= 6
        config.interpolation_domain = varargin{3};
    end
    if nargin == 7
        config.interpolation_threshold = varargin{4};
    end
end

if ~isfield(config,'interpolation_method')
    config.interpolation_method = 'nearest';
end
if ~isfield(config,'interpolation_domain')
    config.interpolation_domain = 'time';
end
if ~isfield(config,'interpolation_threshold')
    config.interpolation_threshold = 0;
end

desiredGrid = config.interpolation_grid;
hrirLen = size(hrirDataL,1);
numDirs = size(desiredGrid,1);
numMeas = size(measuredGrid,1);
hrirL = zeros(hrirLen, numDirs);
hrirR = zeros(hrirLen, numDirs);

% Normalize vectors to be on unit sphere
desiredGrid  = desiredGrid ./(sqrt(dot(desiredGrid ,desiredGrid ,2))*ones(1,size(desiredGrid ,2)));
measuredGrid = measuredGrid./(sqrt(dot(measuredGrid,measuredGrid,2))*ones(1,size(measuredGrid,2)));

switch lower(config.interpolation_method)
    case 'nearest' % Find nearest measured HRTFs
        for ii = 1:numDirs
            distVec = sqrt(sum((measuredGrid - ones(numMeas,1)*desiredGrid(ii,:)).^2,2));
            indx = find(distVec == min(distVec),1,'first');
            hrirL(:,ii) = hrirDataL(:,indx);
            hrirR(:,ii) = hrirDataR(:,indx);
            desiredGrid(ii,:) = measuredGrid(indx,:);
        end
    case {'natural','linear','sh'} % Interpolate HRTFs
        w = interpWeights(measuredGrid, desiredGrid, lower(config.interpolation_method));
        
        % Apply interpolation threshold
        interpNeeded = ~zeros(1,numDirs); % for logical indexing of which positions need interpolation
        for ii = 1:numDirs
            distVec = sqrt(sum((measuredGrid - ones(numMeas,1)*desiredGrid(ii,:)).^2,2));
            indx = find(distVec == min(distVec),1,'first');
            angDist = acosd(dot(measuredGrid(indx,:),desiredGrid(ii,:),2));
            if angDist < config.interpolation_threshold
                interpNeeded(ii) = false; % prevent overwriting below
                % Copy measurements directly
                hrirL(:,ii) = hrirDataL(:,indx);
                hrirR(:,ii) = hrirDataR(:,indx);
                desiredGrid(ii,:) = measuredGrid(indx,:);
            end
        end
        
        [irL, irR, dL, dR, d0] = SABRE_RemoveHRTFDelays(hrirDataL, hrirDataR);
        dLi = dL*w(:,interpNeeded);
        dRi = dR*w(:,interpNeeded);
        switch lower(config.interpolation_domain)
            case 'time'
                irLi = irL*w(:,interpNeeded);
                irRi = irR*w(:,interpNeeded);
            case 'frequency'
                HdBL = mag2db(abs(fft(hrirDataL,hrirLen,1)));
                HdBR = mag2db(abs(fft(hrirDataR,hrirLen,1)));
                irLi = minimumPhase(ifft(db2mag(HdBL*w(:,interpNeeded)),hrirLen,1,'symmetric'));
                irRi = minimumPhase(ifft(db2mag(HdBR*w(:,interpNeeded)),hrirLen,1,'symmetric'));
                dLi = dLi + d0;
                dRi = dRi + d0;
        end
        [hrirL(:,interpNeeded), hrirR(:,interpNeeded)] = SABRE_AddHRTFDelays(irLi, irRi, dLi, dRi);
        % TODO: Add other interpolation methods here...
end

end

function w = interpWeights(posIn,posOut,METHOD,OPTION)

narginchk(2,4);
if nargin < 3
    METHOD = 'linear';
end

if strcmpi(METHOD,'sh')
    if nargin < 4 || isempty(OPTION)
        maxOrder = 4;
    else
        maxOrder = OPTION;
    end
    YmatrixIn = SABRE_SphericalHarmonic(maxOrder, posIn);
    YmatrixOut = SABRE_SphericalHarmonic(maxOrder, posOut);
    w = YmatrixIn\YmatrixOut; % numPosIn-by-numPosOut
else
    numPosIn = size(posIn,1);
    numPosOut = size(posOut,1);
    w = zeros(numPosIn,numPosOut);
    
    for jj = 1:numPosOut
        [y, p, ~] = cart2sph(posOut(jj,1),posOut(jj,2),posOut(jj,3));
        Rz = [cos(y) -sin(y) 0; sin(y) cos(y) 0; 0 0 1];
        Ry = [cos(p) 0 -sin(p); 0 1 0; sin(p) 0 cos(p)];
        
        posInR = posIn*Rz*Ry;
        [posInS(:,1),posInS(:,2),~] = cart2sph(posInR(:,1),posInR(:,2),posInR(:,3));
        
        % Get "impulse responses" of interpolation function
        for ii = 1:numPosIn
            v = zeros(numPosIn,1);
            v(ii) = 1;
            F = scatteredInterpolant(posInS,v,METHOD);
            w(ii,jj) = F([0 0]);
        end
    end
end

end