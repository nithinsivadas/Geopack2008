function [feet,BGEO,eqGEO,eqBGEO] = nithin_find_foot_point_fast(magFieldNo,maxLength,...
    sysaxes,thisTime,x1,x2,x3,stop_alt,maginput)

if sysaxes ~=1
    xGEO = onera_desp_lib_coord_trans([x1,x2,x3],[sysaxes 1],thisTime);
else
    xGEO = [x1, x2, x3];
end

if isempty(maxLength)
    maxLength = 1000; %not used now, hardcoded in fortran
end

[PARMOD,IOPT,EXNAME] = get_parmod(magFieldNo,maginput);
RLIM = maxLength;

INNAME = 'GEOPACK_IGRF_GSM';
t = datetime(thisTime,'ConvertFrom','datenum');

inputStr = [num2str(year(t)),' ',num2str(day(t,'dayofyear')),' ',...
    num2str(hour(t)),' ',num2str(minute(t)),' ',num2str(second(t)),...
    ' ',num2str(xGEO(1)),' ',num2str(xGEO(2)),' ',num2str(xGEO(3)),...
    ' ',num2str(stop_alt),' ',num2str(PARMOD(1)),' ',num2str(PARMOD(2)),...
    ' ',num2str(PARMOD(3)),' ',num2str(PARMOD(4)),' ',num2str(PARMOD(5)),...
    ' ',num2str(PARMOD(6))];

mpath = split(mfilename('fullpath'),filesep);
mpath{end} = ['run_',EXNAME,'_Fast'];
exe = strjoin(mpath,filesep);
if ispc, exe = [exe,'.exe']; end
cmd = [exe,' ',inputStr];

[status,dat] = system(cmd);

if status ~= 0, error(dat), end

arr = cell2mat(textscan(dat, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',...
    'ReturnOnError', false));

FN = arr(2:4);
FS = arr(5:7);

feet.north = onera_desp_lib_coord_trans(FN,[1 0],thisTime);
feet.south = onera_desp_lib_coord_trans(FS,[1 0],thisTime);

feet.number = arr(1);

eqGEO = arr(8:10);
eqBGEO = arr(11:13);
BGEO = arr(15:17);


end

function [PARMOD,IOPT,magStr] = get_parmod(magFieldNo,maginput)

PARMOD = zeros(10,1);

if magFieldNo==4
    kp = round(maginput(1)/10)+1;
    magStr = 'T89';
    PARMOD(1) = kp;
    IOPT = kp;
elseif magFieldNo==7
    magStr = 'T96';
    PARMOD(1) = maginput(5);
    PARMOD(2) = maginput(2);
    PARMOD(3) = maginput(6);
    PARMOD(4) = maginput(7);
    IOPT = 0;
elseif magFieldNo==9
    magStr = 'T01';
    PARMOD(1) = maginput(5);
    PARMOD(2) = maginput(2);
    PARMOD(3) = maginput(6);
    PARMOD(4) = maginput(7);
    PARMOD(5) = maginput(8);
    PARMOD(6) = maginput(9);
    IOPT=0;
else
    error('GEOPACK version does not contain the specified external field.');
end

end