function data = generate_foot_point(magFieldNo,maxLength,...
    sysaxes,timeArr,x1Arr,x2Arr,x3Arr,stop_alt,maginputArr)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% Initialize environment variables
if isunix, setenv('LD_LIBRARY_PATH',''); end
%% Generate input
mpath = split(mfilename('fullpath'),filesep);
cpath = pwd;
cd(strjoin(mpath(1:end-1),filesep));
formatSpec = ['%4u %3u %2u %2u %2u',...
' %8.2f %8.2f %8.2f',' %8.2f',repmat(' %8.2f',1,10),'\n'];

fileID = fopen('inputT.dat','w');
for i = 1:1:length(timeArr)
    generate_foot_point_input(fileID,formatSpec,magFieldNo,maxLength,...
        sysaxes,timeArr(i),x1Arr(i),x2Arr(i),x3Arr(i),stop_alt,maginputArr(i,:));
end
fclose(fileID);
%% Caclulate foot points using the fortran code
mpath{end} = ['run_',get_fortran_code_name(magFieldNo)];
exe = strjoin(mpath,filesep);
if ispc, exe = [exe,'.exe']; end

[status,dat] = system(exe);

if status~=0
    disp(dat);
    error('Fortran code had some error');
end

%% Read the output data file into memory
out = importdata('outputF.dat');
out(out==99999) = nan;
data.foot = out(:,1);
data.footNGEO = out(:,2:4);
data.footSGEO = out(:,5:7);
data.eqGEO = out(:,8:10);
data.eqBGEO = out(:,11:13);
data.BGEO = out(:,15:17);

cd(cpath);

%% Run the fortran code


end

function fname = get_fortran_code_name(magFieldNo)

if magFieldNo==7
    fname='T96_v1';
elseif magFieldNo==9
    fname='T01_v1';
else
    error('GEOPACK version does not contain the specified external field');
end
    
end
