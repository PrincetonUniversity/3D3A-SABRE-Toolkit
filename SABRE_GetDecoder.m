function [decodingMatrix, globalparams] = SABRE_GetDecoder(config, flags)
%SABRE_GetDecoder Load or design an ambisonics decoder.
%   [D, PARAMS] = SABRE_GetDecoder(C, F) returns decoder matrix D and a
%       cell array of decoder parameters PARAMS given CONFIG settings and
%       FLAGS.
%
%   See also SABRE_BasicDecoder, SABRE_ReadConfigFile.

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

narginchk(2,2);

if flags.do_load_decoder
    % Load decoder from existing ambiX .config file
    [decodingMatrix, ~, globalparams] = SABRE_ReadConfigFile(config.decoder_file);
    if size(decodingMatrix,1) ~= size(config.hrir_grid,1)
        error('Size mismatch between speaker grid and decoder.');
    end
else
    if flags.do_quadrature_decoder
        % Compute quadrature decoder
        [decodingMatrix, globalparams] = SABRE_BasicDecoder(config.decoder_order, config.interpolation_grid, config.weights);
    else
        % Compute basic (pseudoinverse) decoder
        [decodingMatrix, globalparams] = SABRE_BasicDecoder(config.decoder_order, config.hrir_grid);
    end
end

end