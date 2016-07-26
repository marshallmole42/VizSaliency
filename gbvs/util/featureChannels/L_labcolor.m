function out = L_labcolor( fparam, img , imgR, imgG, imgB, typeidx )
%L_LABCOLOR Summary of this function goes here
%   Detailed explanation goes here
if ( nargin == 1 )
  out.weight = fparam.labcolorWeight;
  out.numtypes = 3;
  out.descriptions{1} = 'LAB lightness Channel';
  out.descriptions{2} = 'LAB Color Channel 1';
  out.descriptions{3} = 'LAB Color Channel 2';
else
  rgb = repmat( imgR , [ 1 1 3 ] );
  rgb(:,:,2) = imgG;
  rgb(:,:,3) = imgB;
  lab = rgb2lab( rgb );

  if ( typeidx == 1 )
    out.map = lab(:,:,1);
  elseif ( typeidx == 2 )
    out.map = lab(:,:,2);
  elseif ( typeidx == 3 )
    out.map = lab(:,:,3);
  end
end

end

