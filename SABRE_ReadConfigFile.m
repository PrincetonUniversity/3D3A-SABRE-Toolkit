function [D, HRTFfilenames, globalparams] = SABRE_ReadConfigFile(fname)
%SABRE_ReadConfigFile Read an ambiX binaural preset file.
%   [D, NAMES, PARAMS] = SABRE_ReadConfigFile(CFP) reads the binaural preset
%       file CFP and returns the global PARAMS, the HRTF file NAMES and the
%       decoder matrix D.
%
%   See also SABRE_WriteConfigFile.

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

fid = fopen(fname);
globalparams = cell(1);
numSpkrs = 0;
numHOAch = 0;

while ~feof(fid)
    tsplit = strsplit(fgetl(fid));
    switch upper(tsplit{1})
        case '#GLOBAL'
            numParams = 0;
            tline = fgetl(fid);
            while ~strcmpi(tline,'#END')
                numParams = numParams + 1;
                param = strsplit(tline);
                paramName = param{1};
                paramVal = strjoin(param(2:end));
                globalparams{numParams,1} = paramName;
                globalparams{numParams,2} = paramVal;
                tline = fgetl(fid);
            end
        case '#HRTF'
            % TODO: handle HRTF options
            % e.g. <gain factor> <delay in ms> <swap left right channel>
            if numSpkrs == 0
                HRTFfilenames = cell(1);
                tline = fgetl(fid);
                while ~strcmpi(tline,'#END')
                    numSpkrs = numSpkrs + 1;
                    HRTFfilenames{numSpkrs,1} = tline;
                    tline = fgetl(fid);
                end
            else
                HRTFfilenames = cell(numSpkrs,1);
                for ii = 1:numSpkrs
                    HRTFfilenames{ii,1} = fgetl(fid);
                end
            end
        case '#DECODERMATRIX'
            if numHOAch == 0 && numSpkrs == 0
                Drows = cell(1);
                tline = fgetl(fid);
                ii = 1;
                while ~strcmpi(tline,'#END')
                    Drows{ii,1} = sscanf(tline,'%f').';
                    tline = fgetl(fid);
                    ii = ii + 1;
                end
                D = cell2mat(Drows);
                [numSpkrs, numHOAch] = size(D);
            elseif numHOAch == 0 && numSpkrs ~= 0
                Drows = cell(numSpkrs,1);
                for ii = 1:numSpkrs
                    tline = fgetl(fid);
                    Drows{ii,1} = sscanf(tline,'%f').';
                end
                D = cell2mat(Drows);
                numHOAch = size(D,2);
            elseif numHOAch ~= 0 && numSpkrs == 0
                D = fscanf(fid,'%f',[numHOAch,inf])';
                numSpkrs = size(D,1);
            else
                D = fscanf(fid,'%f',[numHOAch,numSpkrs])';
            end
    end
end

fclose(fid);

end