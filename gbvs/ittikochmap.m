function out = ittikochmap( img, channels )

params = makeGBVSParams;
params.useIttiKochInsteadOfGBVS = 1;
if nargin == 1
    params.channels = 'CIO';
elseif nargin == 2
    params.channels = channels;
end
params.verbose = 0;
params.unCenterBias = 0;

%
% uncomment the line below (ittiDeltaLevels = [2 3]) for more faithful implementation 
% (however, known to give crappy results for small images i.e. < 640 in height or width )
%
% params.ittiDeltaLevels = [ 2 3 ];
%

if ( ischar(img) == 1 ) img = imread(img); end
if ( strcmp(class(img),'uint8') == 1 ) img = double(img)/255; end

params.salmapmaxsize = round( max(size(img))/8 );

out = gbvs(img,params);
