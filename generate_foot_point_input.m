function generate_foot_point_input(fileID,formatSpec,magFieldNo,maxLength,...
    sysaxes,thisTime,x1,x2,x3,stop_alt,maginput)

if sysaxes ~=1
    xGEO = onera_desp_lib_coord_trans([x1,x2,x3],[sysaxes 1],thisTime);
else
    xGEO = [x1, x2, x3];
end

if isempty(maxLength)
    maxLength = 1000; %not used now, hardcoded in fortran
end

[PARMOD] = get_parmod(magFieldNo,maginput);
% RLIM = maxLength;

% INNAME = 'GEOPACK_IGRF_GSM';
t = datetime(thisTime,'ConvertFrom','datenum');


fprintf(fileID,formatSpec,year(t),day(t,'dayofyear'),...
    hour(t),minute(t),second(t),xGEO(:),stop_alt,PARMOD(:));

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