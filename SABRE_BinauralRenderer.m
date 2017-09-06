function [config, flags] = SABRE_BinauralRenderer(varargin)
%SABRE_BinauralRenderer Create and export a custom ambiX binaural preset.
%   SABRE_BinauralRenderer(CFP, L, SFP) creates a binaural preset saved to
%       CFP (configuration filepath). The function creates a basic decoder
%       of ambisonics order L and uses the HRTFs in SFP (SOFA filepath).
%
%   SABRE_BinauralRenderer(CFP, L, SFP, ...) uses the renderer settings
%       specified in the pairwise varargin format, as described in
%       SABRE_RendererSettings.
%
%   SABRE_BinauralRenderer(CONFIG, FLAGS) uses the settings
%       specified in the CONFIG struct and obeys the specified FLAGS, where
%       CONFIG and FLAGS are the output variables of SABRE_RendererSettings.
%
%   [CONFIG, FLAGS] = SABRE_BinauralRenderer(...) returns the CONFIG
%       settings and FLAGS used in the design.
%
%   Example:
%       SABRE_BinauralRenderer(CFP, L, SFP, 'compact', true) creates a
%           compacted basic decoder of order L using the HRTFs in SFP and
%           saves the preset as CFP.
%
%   See also SABRE_RendererSettings, SABRE_LoadHRTFs, SABRE_GetDecoder.

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

narginchk(2,inf);


%% Determine config settings and flags
switch nargin
    case 2
        config = varargin{1};
        flags = varargin{2};
    otherwise
        temp = {'Output', varargin{1}, 'Order', varargin{2}, 'HRTF', varargin{3}};
        [config, flags] = SABRE_RendererSettings(cat(2,temp,varargin(4:end)));
end


%% Load, interpolate, and equalize HRTFs for given speaker positions/HRTF grid
[config.hrirL, config.hrirR, config.hrir_grid, config.sample_rate] = SABRE_LoadHRTFs(config, flags);


%% Load or design decoder matrix and parameters
[config.decoding_matrix, config.global_params] = SABRE_GetDecoder(config, flags);


%% Compact decoder into square matrix
if flags.do_compact_decoder
    config.birL = config.hrirL * config.decoding_matrix;
    config.birR = config.hrirR * config.decoding_matrix;
    config.decoding_matrix = eye((config.decoder_order + 1)^2);
else
    config.birL = config.hrirL;
    config.birR = config.hrirR;
    % config.decoding_matrix unchanged
end


%% Normalize decoder on a per-channel basis
if flags.do_normalize_decoder
    % Per-channel normalization decoder and IRs
    [config.birL, config.birR, config.decoding_matrix] = SABRE_NormalizeDecoder(config.birL, config.birR, config.decoding_matrix);
else
    % Global normalization of BIRs to avoid clipping
    [config.birL, config.birR, ~] = SABRE_NormalizeDecoder(config.birL, config.birR);
end


%% Determine .config file directory and basename
[configDir, configName, ~] = fileparts(config.output_file);
if ~isdir(configDir)
    mkdir(configDir);
end


%% Generate BIR .wav files
numBIRs = size(config.decoding_matrix,1);
config.bir_files = cell(numBIRs,1);
for ii = 1:numBIRs
    if flags.do_compact_decoder
        config.bir_files{ii,1} = [configName '_ACN_' int2str(ii-1) '.wav'];
    else
        config.bir_files{ii,1} = [configName '_SPKR_' int2str(ii) '.wav'];
    end
    audiowrite(fullfile(configDir, config.bir_files{ii,1}), [config.birL(:,ii), config.birR(:,ii)], config.sample_rate);
end


%% Export .config file
SABRE_WriteConfigFile(config.output_file, config.decoding_matrix, config.bir_files, config.global_params);


end