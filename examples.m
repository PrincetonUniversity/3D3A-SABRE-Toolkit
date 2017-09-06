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

%   Note: Make sure you've added the SOFA API to your MATLAB search path!

SABRE_Start;

maxOrder = 1;

%% Example 1) Native HRTF grid with compacted (by default) basic decoder

sofaFile = fullfile('hrtfs','Subject2.sofa');
configFile = fullfile(SABRE_AmbiXPath,'3D3A-SABRE','ex1-Subject2.config');
[config, flags] = SABRE_BinauralRenderer(configFile, maxOrder, sofaFile);

%% Example 2) Custom grid with non-compacted basic decoder and diffuse-field EQ

sofaFile = fullfile('hrtfs','Subject2.sofa');
[posMat, ~] = SABRE_LoadGrid(fullfile('grids','fliege_36.mat')); % 36-node Fliege grid
configFile = fullfile(SABRE_AmbiXPath,'3D3A-SABRE','ex2-Subject2-fliege-grid.config');
temp = {'Output', configFile,...
    'Order', maxOrder,...
    'HRTF', sofaFile,...
    'Grid', posMat,...
    'Compact', false,...
    'Equalization', 'diffuse'};
[config, flags] = SABRE_RendererSettings(temp);
[config, flags] = SABRE_BinauralRenderer(config, flags);

%% Example 3) Custom grid with non-compacted quadrature decoder

sofaFile = fullfile('hrtfs','Subject2.sofa');
[posMat, wQList] = SABRE_LoadGrid(fullfile('grids','fliege_36.mat')); % 36-node Fliege grid with quadrature weights
configFile = fullfile(SABRE_AmbiXPath,'3D3A-SABRE','ex3-Subject2-fliege-quad.config');
[config, flags] = SABRE_BinauralRenderer(configFile, maxOrder, sofaFile, 'Grid', posMat, 'Weights', wQList, 'Compact', false);

%% Example 4) Custom grid with compacted (by default) quadrature decoder using natural-neighbor interpolation

sofaFile = fullfile('hrtfs','Subject2.sofa');
[posMat, wQList] = SABRE_LoadGrid(fullfile('grids','fliege_36.mat')); % 36-node Fliege grid with quadrature weights
configFile = fullfile(SABRE_AmbiXPath,'3D3A-SABRE','ex4-Subject2-compact-quad-interp.config');
temp = {'Output', configFile,...
    'Order', maxOrder,...
    'HRTF', sofaFile,...
    'Grid', posMat,...
    'Weights', wQList,...
    'Method', 'natural',...
    'Domain', 'time',...
    'Threshold', 5};
[config, flags] = SABRE_RendererSettings(temp);
[config, flags] = SABRE_BinauralRenderer(config, flags);

%% Example 5) Adding diffuse-field equalized HRTFs to an existing decoder

sofaFile = fullfile('hrtfs','CIPIC_003.sofa');
[posMat, ~] = SABRE_LoadGrid(fullfile('grids','quader.mat'));
quaderConfig = fullfile(SABRE_AmbiXPath,'quader',['quader-o' int2str(maxOrder) '.config']);
configFile = fullfile(SABRE_AmbiXPath,'3D3A-SABRE','ex5-CIPIC_003-quader.config');
[config, flags] = SABRE_BinauralRenderer(configFile, maxOrder, sofaFile, 'Decoder', quaderConfig, 'Grid', posMat, 'Equalization', 'diffuse');