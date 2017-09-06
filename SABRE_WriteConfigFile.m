function SABRE_WriteConfigFile(fname, D, HRTFfilenames, globalparams)
%SABRE_WriteConfigFile Write an ambiX binaural preset file.
%   SABRE_WriteConfigFile(CFP, D, NAMES, PARAMS) writes a binaural preset to
%       the file CFP that consists of the global PARAMS, the HRTFs
%       specified by the file NAMES, and the decoder matrix D.
%
%   See also SABRE_ReadConfigFile.

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

[numSpkrs, numHOAch] = size(D);
numParams = size(globalparams,1);

fid = fopen(fname,'w');

fprintf(fid, '#GLOBAL\n');
for pp = 1:numParams
    fprintf(fid,'%s %s\n',globalparams{pp,1},globalparams{pp,2});
end
fprintf(fid, '#END\n\n');


fprintf(fid, '#HRTF\n');
for ii = 1:numSpkrs
    fprintf(fid,[HRTFfilenames{ii,1},'\n']);
end
fprintf(fid, '#END\n\n');


fprintf(fid, '#DECODERMATRIX\n');
for ii = 1:numSpkrs
    for jj = 1:numHOAch
        fprintf(fid,'%17.15f',D(ii,jj));
        if jj < numHOAch
            fprintf(fid,'\t');
        end
    end
    fprintf(fid,'\n');
end
fprintf(fid, '#END\n');

fclose(fid);

end