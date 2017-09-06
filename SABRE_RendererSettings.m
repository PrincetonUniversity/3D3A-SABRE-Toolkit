function [config, flags] = SABRE_RendererSettings(varargin)
%SABRE_RendererSettings Assemble inline binaural renderer settings into structs.
%   [C, F] = SABRE_RendererSettings(...) creates binaural renderer settings
%       C and flags F based on the following inputs:
%       {'output', PATH} - Specify output file path for the ambiX .config
%           file. NOTE: this input is mandatory.
%
%       {'order', L} - Specify the ambisonics order of the decoder. NOTE:
%           this input is mandatory.
%
%       {'hrtf', PATH} - Specify the SOFA file path for the HRTFs. NOTE:
%           this input is mandatory
%
%       {'grid', R} - Use a custom speaker grid specified by R. R should be
%           a P-by-3 matrix, where each row is a Cartesian vector. By
%           default, the entire measurement grid in the SOFA file is used.
%
%       {'method', METHOD} - Specify the interpolation METHOD to be
%           used. The available options are listed in SABRE_InterpolateHRTFs.
%           By default, nearest-neighbor interpolation is used.
%
%       {'domain', DOMAIN} - Specify the DOMAIN ('time' or 'frequency') in
%           which to interpolate. Must also specify an interpolation
%           METHOD.
%
%       {'threshold', THRESHOLD} - Specify the THRESHOLD for interpolation.
%           If a measurement exists within THRESHOLD degrees from a desired
%           position, then the nearest neighbor to that desired position is
%           used.
%
%       {'equalization', TYPE} - Apply equalization of a given TYPE to the
%           HRTFs. The available types are listed in SABRE_EqualizationFilters.
%           By default, no equalization is applied.
%
%       {'sample rate', Fs} - Specify desired HRTF sample rate for the
%           decoder. By default, the sample rate of the HRTFs in the SOFA
%           file is used for the decoder impulse responses.
%
%       {'decoder', PATH} - Load existing ambiX decoder. PATH should be the
%           path to an existing ambiX .config file. NOTE: to use this
%           option, you MUST also specify the corresponding grid.
%
%       {'weights', W} - Use quadrature-weighted decoder with weights W. W 
%           should be a length P vector. NOTE: Weights are ignored if an
%           existing ambiX decoder is used.
%
%       {'compact', X} - Compact the decoder into a square matrix. X should
%           evaluate to either true or false.
%
%       {'normalization', X} - Normalize the decoder on a per-channel basis.
%           X should evaluate to either true or false.
%
%   See also SABRE_BinauralRenderer.

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

if nargin == 1 && iscell(varargin)
    varargin = varargin{1};
end

% Set default flags
flags.do_interpolate = false; % Interpolate HRTFs
flags.do_equalize = false; % Equalize HRTFs
flags.do_resample = false; % Resample HRTFs
flags.do_load_decoder = false; % Load exising decoder
flags.do_quadrature_decoder = false; % Compute quadrature decoder
flags.do_compact_decoder = true; % Compact decoder
flags.do_normalize_decoder = true; % Normalize decoder

% Check for user-specified output file
indx = find(strcmpi(varargin,'output'),1);
if ~isempty(indx)
    config.output_file = varargin{indx+1};
    varargin(indx:indx+1) = [];
else
    error('Must specify output file!');
end

% Check for user-specified decoder order
indx = find(strcmpi(varargin,'order'),1);
if ~isempty(indx)
    config.decoder_order = varargin{indx+1};
    varargin(indx:indx+1) = [];
else
    error('Must specify decoder order!');
end

% Check for user-specified HRTF file
indx = find(strcmpi(varargin,'hrtf'),1);
if ~isempty(indx)
    config.hrtf_file = varargin{indx+1};
    varargin(indx:indx+1) = [];
else
    error('Must specify HRTF file!');
end

% Check for user-specified interpolation grid
indx = find(strcmpi(varargin,'grid'),1);
if ~isempty(indx)
    flags.do_interpolate = true;
    config.interpolation_grid = varargin{indx+1};
    varargin(indx:indx+1) = [];
end

% Check for user-specified interpolation method
indx = find(strcmpi(varargin,'method'),1);
if ~isempty(indx)
    config.interpolation_method = varargin{indx+1};
    varargin(indx:indx+1) = [];
end

% Check for user-specified interpolation domain
indx = find(strcmpi(varargin,'domain'),1);
if ~isempty(indx)
    config.interpolation_domain = varargin{indx+1};
    varargin(indx:indx+1) = [];
end

% Check for user-specified interpolation threshold
indx = find(strcmpi(varargin,'threshold'),1);
if ~isempty(indx)
    config.interpolation_threshold = varargin{indx+1};
    varargin(indx:indx+1) = [];
end

% Check for user-specified equalization type
indx = find(strcmpi(varargin,'equalization'),1);
if ~isempty(indx)
    flags.do_equalize = true;
    config.equalization_type = varargin{indx+1};
    varargin(indx:indx+1) = [];
end

% Check for user-specified sample rate
indx = find(strcmpi(varargin,'sample rate'),1);
if ~isempty(indx)
    flags.do_resample = true;
    config.sample_rate = varargin{indx+1};
    varargin(indx:indx+1) = [];
end

% Check for user-specified existing .config file
indx = find(strcmpi(varargin,'decoder'),1);
if ~isempty(indx)
    flags.do_load_decoder = true;
    config.decoder_file = varargin{indx+1};
    varargin(indx:indx+1) = [];
    
    % Also, by default, don't compact
    flags.do_compact_decoder = false;
end

% Check for user-specified quadrature weights
indx = find(strcmpi(varargin,'weights'),1);
if ~isempty(indx)
    flags.do_quadrature_decoder = true;
    config.weights = varargin{indx+1};
    varargin(indx:indx+1) = [];
end

% User override of decoder compacting defaults
indx = find(strcmpi(varargin,'compact'),1);
if ~isempty(indx)
    flags.do_compact_decoder = varargin{indx+1};
    varargin(indx:indx+1) = [];
end

% User override of decoder normalization defaults
indx = find(strcmpi(varargin,'normalization'),1);
if ~isempty(indx)
    flags.do_normalize_decoder = varargin{indx+1};
    varargin(indx:indx+1) = [];
end

%% Error checking
if flags.do_load_decoder && ~isfield(config,'interpolation_grid')
    error('Cannot load decoder without specifying corresponding speaker grid!');
end

if numel(varargin) > 0
    warning('There were unused options:');
    disp(varargin)
end

end