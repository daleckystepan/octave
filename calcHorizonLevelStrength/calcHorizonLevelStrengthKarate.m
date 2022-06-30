function horizonLevelStrength = calcHorizonLevelStrengthKarate(rc,angle)

  # start with 1.0 at center stick, 0.0 at max stick deflection:
  horizonLevelStrength = 1.0 - sqrt(rc*rc+rc*rc);
  # constrainf
  if (horizonLevelStrength > 1.0)
    horizonLevelStrength = 1.0;
  elseif (horizonLevelStrength < 0.0)
    horizonLevelStrength = 0.0;
  end

  # 0 at level, 90 at vertical, 180 at inverted (degrees):
  currentInclination = abs(angle / 10);

  horizon_tilt_effect = 75; # 75 default - bends in the middle
  horizonFactorRatio = (100 - horizon_tilt_effect) * 0.01;


  horizonTransition = sqrt(75/100)*100; # 75 default - point in RC where it starts to work

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
