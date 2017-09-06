function [hrirL, hrirR, posMat, Fs] = SABRE_LoadHRTFs(varargin)
%SABRE_LoadHRTFs Load HRTFs from a SOFA file.
%   [HL, HR, R, Fs] = SABRE_LoadHRTFs(FILE) returns left and right HRIRs, HL
%       and HR, specified at positions R and at sampling rate Fs. FILE
%       should be the path to the SOFA-formatted HRIR file, relative to the
%       default SOFA directory. HL and HR will be K-by-P matrices where K
%       is the length of a single HRIR and P is the number of directions;
%       R will be a P-by-3 matrix, where each row is a Cartesian vector.
%
%   [HL, HR, R, Fs] = SABRE_LoadHRTFs(CONFIG, FLAGS) returns HRIRs according
%       to the CONFIG settings and FLAGS.
%
%   See also SABRE_InterpolateHRTFs, SABRE_EqualizationFilters, SABRE_EqualizeHRTFs.
%
%   Note: Make sure you've added the SOFA API to your MATLAB search path!

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

narginchk(1,2);
switch nargin
    case 1
        % Must specify some dummy settings to load the HRTFs
        [config, flags] = SABRE_RendererSettings('Output', '', 'Order', 1, 'HRTF', varargin{1});
    case 2
        config = varargin{1};
        flags = varargin{2};
end

% Load HRIRs
hrtf = SOFAload(config.hrtf_file);
hrirDataL = squeeze(hrtf.Data.IR(:,1,:)).';
hrirDataR = squeeze(hrtf.Data.IR(:,2,:)).';
switch lower(hrtf.SourcePosition_Type)
    case 'cartesian'
        DIST_Units = hrtf.SourcePosition_Units;
        hrirPosMat = hrtf.SourcePosition;
    case 'spherical'
        AZIM = hrtf.SourcePosition(:,1);
        ELEV = hrtf.SourcePosition(:,2);
        DIST = hrtf.SourcePosition(:,3);
        
        commaPos = strfind(hrtf.SourcePosition_Units,',');
        AZIM_Units = char(extractBefore(hrtf.SourcePosition_Units, commaPos(1)));
        ELEV_Units = char(extractBetween(hrtf.SourcePosition_Units, commaPos(1)+1, commaPos(2), 'Boundaries', 'exclusive'));
        DIST_Units = char(extractAfter(hrtf.SourcePosition_Units, commaPos(2)+1));
        
        % Convert degrees to radians
        if strcmpi(AZIM_Units,'degree')
            AZIM = AZIM*pi/180;
        end
        if strcmpi(ELEV_Units,'degree')
            ELEV = ELEV*pi/180;
        end
        [hrirPosMat(:,1), hrirPosMat(:,2), hrirPosMat(:,3)] = sph2cart(AZIM,ELEV,DIST);
end
if strcmpi(DIST_Units,'centimetre')
    hrirPosMat = hrirPosMat/100;
end
sofaFs = hrtf.Data.SamplingRate;
clear hrtf;

% Compute equalization filters if needed
if flags.do_equalize
    % Use the full HRTF to design the EQ filters
    eqFilters = SABRE_EqualizationFilters(hrirDataL, hrirDataR, hrirPosMat, sofaFs, config.equalization_type);
else
    % Dummy EQ filters
    eqFilters = zeros(1024,2);
    eqFilters(1,:) = 1;
end

% Interpolate HRTFs if specified
if flags.do_interpolate
    % Use desired speaker positions
    [hrirL, hrirR, posMat] = SABRE_InterpolateHRTFs(hrirDataL, hrirDataR, hrirPosMat, config);
else
    % Use native HRIR grid and all HRIRs
    posMat = hrirPosMat;
    hrirL = hrirDataL;
    hrirR = hrirDataR;
end

% Equalize HRTFs if desired
if flags.do_equalize
    % Equalize only the interpolated HRTFs
    [hrirL, hrirR] = SABRE_EqualizeHRTFs(hrirL, hrirR, eqFilters);
end

% Resample HRTFs if desired
if flags.do_resample
    if config.sample_rate ~= sofaFs
        hrirL = resample(hrirL, config.sample_rate, sofaFs);
        hrirR = resample(hrirR, config.sample_rate, sofaFs);
    end
    Fs = config.sample_rate;
else
    Fs = sofaFs;
end

end