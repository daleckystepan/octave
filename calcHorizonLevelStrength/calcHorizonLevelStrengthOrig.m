function horizonLevelStrength = calcHorizonLevelStrengthOrig(rc,angle)

  # start with 1.0 at center stick, 0.0 at max stick deflection:
  horizonLevelStrength = 1.0 - abs(max(rc,rc));

  # 0 at level, 90 at vertical, 180 at inverted (degrees):
  currentInclination = abs(angle) / 10.0;

  horizon_tilt_effect = 75; # 75 default - bends in the middle
  horizonFactorRatio = (100 - horizon_tilt_effect) * 0.01;


  horizonTransition = 75; # 75 default - point in RC where horizon starts to work

  if (horizonFactorRatio < 1.0)
    inclinationLevelRatio = (180 - currentInclination) / 180 * (1.0 - horizonFactorRatio) + horizonFactorRatio;
    sensitFact = horizonTransition * inclinationLevelRatio;
  else
    sensitFact = horizonTransition;
  endif

  if (sensitFact <= 0.0)
    horizonLevelStrength = 0.0
  else
    horizonLevelStrength = ((horizonLevelStrength - 1) * (100 / sensitFact)) + 1;
  end


  # constrainf
  if (horizonLevelStrength > 1.0)
    horizonLevelStrength = 1.0;
  elseif (horizonLevelStrength < 0.0)
    horizonLevelStrength = 0.0;
  end

  #printf("f(%d,%d)=%d\n", rc, angle, horizonLevelStrength)
end
