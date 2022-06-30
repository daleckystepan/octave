clear;

FUNCTIONS{1} = @calcHorizonLevelStrengthOrig;
FUNCTIONS{2} = @calcHorizonLevelStrengthBellshaped;
FUNCTIONS{3} = @calcHorizonLevelStrengthKarate;
FUNCTIONS{4} = @calcHorizonLevelStrengthTesting;

RC    = -1.5:0.025:1.5;
ANGLE = -180:5:180;
ANGLE_ZERO_INDEX = round(length(ANGLE)/2);
ANGLE_45_INDEX = round(length(ANGLE)/8);

[RCmesh,ANGLEmesh] = meshgrid(RC, ANGLE);

Z = zeros(length(ANGLE), length(RC), length(FUNCTIONS));

for fi = 1 : length(FUNCTIONS)

  # Fill Z data
  for i = 1 : length(RCmesh(:,1))
    for j = 1 : length(ANGLEmesh(1,:))
      Z(i, j, fi)  = FUNCTIONS{fi}( RCmesh(i,j), ANGLEmesh(i,j)*10 );
    end
  end

end


ROWS = round(length(FUNCTIONS)/2);
COLS = 2;

sROWS = ROWS*2;
sCOLS = COLS*3;

for fi = 1 : length(FUNCTIONS)
  index = (fi-1)*6 - mod(fi-1,COLS)*(COLS+1) + 1;
  subplot(sROWS, sCOLS, [index index+1 index+sCOLS index+sCOLS+1])
  surf(RCmesh, ANGLEmesh, Z(:,:,fi));
  grid on;
  box on;
  title(sprintf('%s', func2str(FUNCTIONS{fi})), "fontsize", 16);
  xlabel('RC');
  xlim([-1 1]);
  xticks(-1:0.25:1);
  ylabel('Angle [deg]');
  ylim([-180 180]);
  yticks(-180:45:180);

  subplot(sROWS, sCOLS, index+COLS)
  plot(RC, Z(ANGLE_ZERO_INDEX,:,fi));
  grid on;
  box on;
  title(sprintf('%s\nslice @ angle = 0 deg', func2str(FUNCTIONS{fi})), "fontsize", 16);
  xlabel('RC');
  xlim([-1 1]);
  xticks(-1:0.25:1);
  ylabel('HorizonLevelStrength');

  subplot(sROWS, sCOLS, index+sCOLS+1+1)
  plot(RC, Z(ANGLE_45_INDEX,:,fi));
  grid on;
  box on;
  title(sprintf('%s\nslice @ angle = -45 deg', func2str(FUNCTIONS{fi})), "fontsize", 16);
  xlabel('RC');
  xlim([-1 1]);
  xticks(-1:0.25:1);
  ylabel('HorizonLevelStrength');
end

