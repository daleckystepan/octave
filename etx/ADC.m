clear ; close all; clc
pkg load signal

# pkg install -forge control signal

NAMES = {'YAW', 'PITCH', 'ROLL', 'THR', 'POT1', 'POT2', 'POT3', 'SLIDER1', 'SLIDER2'};

#data = csvread('tx16sfw2khz.log');
#SAMPLE_RATE_HZ = 2000;

#data = csvread('jye.log');
#data = csvread('etx285hz.log');
#data = csvread('etx2khz.log');
#data = csvread('etx2khz_3cycles.log');
#data = csvread('etx2khz_66ms.log');
#SAMPLE_RATE_HZ = round(1000*length(data(:,1))/(data(end,1)-data(1,1)))/10;

#data = csvread('etx1khz.log');
#data = csvread('etx1khz_patched.log');
data = csvread('etx-logs/etx_1999fixed.log');
SAMPLE_RATE_HZ = length(data)/((data(end,1)-data(1,1))/168e6);

# pwelch
overlap = 0.5;
window = hann(4096);
window_resample = hann(1024);

# spectogram
step = floor(50*SAMPLE_RATE_HZ/1000);   # one spectral slice every 50 ms
win = floor(1000*SAMPLE_RATE_HZ/1000);  # 1000 ms data window
fftn = 2^nextpow2(win); # next highest power of 2
over = win - step;
win = hann(win);


# RC setting
RC_RATE_HZ = 200;
resample_nth = floor(SAMPLE_RATE_HZ/RC_RATE_HZ);
SUB_HZ = floor(SAMPLE_RATE_HZ/resample_nth);

# Filtering
CUTOFF = 100;

plot_rows = 4;
plot_cols = 1;

#for i = 0:3
#for i = 0:8
for i = 0:3
  figure;

  ### pwelch ###
  x = data(:,i+2);
  [Pyy,Fy] = pwelch(x,window,overlap,length(x),SAMPLE_RATE_HZ);
  Pyy = 10*log10(Pyy);

  # Resample data to simulate old ETX behavior: sampling at RC refresh rate
  xc = x(1:resample_nth:end);
  [Pc,Fc] = pwelch(xc,window_resample,overlap,length(xc),SAMPLE_RATE_HZ/resample_nth);

  ### Lowpass ###
  [b,a] = butter(1,CUTOFF/SAMPLE_RATE_HZ*2,'low');
  xf = filter(b,a,x);
  [Pyyf,Fyf] = pwelch(xf,window,overlap,length(xf),SAMPLE_RATE_HZ);
  Pyyf = 10*log10(Pyyf);

  min = mean(Pyy)*1.25;


  ### Spectrum full ###
  subplot(plot_rows, plot_cols, 1)
  hold on
  plot(Fy,Pyy);
  #plot(Fyf,Pyyf);
  hold off
  grid on
  box on
  title(sprintf('G%d %s @ %d Hz',i,NAMES{i+1},SAMPLE_RATE_HZ), "fontsize", 16)
  xlabel('Frequency (Hz)')
  ylabel('PSD (dB/Hz)')
  ylim([min inf])
  xticks(0:100:SAMPLE_RATE_HZ)
  legend(sprintf('Raw ADC data @ %d Hz', SAMPLE_RATE_HZ), sprintf('Butterworth order 1, cutoff %d Hz @ %d Hz',CUTOFF,SAMPLE_RATE_HZ))

  A = get(gca,'position');
  A(1,1) = A(1,1) * 0.5;  # x pos
  A(1,2) = A(1,2) * 0.95; # y pos
  A(1,3) = A(1,3) * 1.1;  # horizontal size
  A(1,4) = A(1,4) * 1.7;  # vertical size
  set(gca,'position',A);


  ### Spectrum sub ###
  subplot(plot_rows, plot_cols, 2)
  hold on
  plot(Fy,Pyy);
  plot(Fc,10*log10(Pc));
  hold off
  grid on
  box on
  title(sprintf('G%d sub %d Hz',i,SUB_HZ/2), "fontsize", 16)
  xlabel('Frequency (Hz)')
  xlim([0 SUB_HZ/2])
  xticks(0:10:SUB_HZ/2)
  ylabel('PSD (dB/Hz)')
  ylim([min inf])
  legend(sprintf('Raw ADC @ %d Hz', SAMPLE_RATE_HZ), sprintf('Resampled ADC @ %d Hz',SUB_HZ))

  A = get(gca,'position');
  A(1,1) = A(1,1) * 0.5;  # x pos
  A(1,2) = A(1,2) * 0.9;  # y pos
  A(1,3) = A(1,3) * 1.1;  # horizontal size
  A(1,4) = A(1,4) * 1.7;  # vertical size
  set(gca,'position',A);


  ### Spectogram ###
  [S, f, t] = specgram(x,fftn,SAMPLE_RATE_HZ,win,over);
  S = abs(S).^2 / (SAMPLE_RATE_HZ*fftn);
  S = 10*log10(S);


  ### Spectogram full ###
  subplot(plot_rows, plot_cols, 3)
  imagesc (t, f, S);
  title(sprintf('G%d spectogram raw ADC',i), "fontsize", 16)
  axis xy
  #colormap(jet)
  colorbar
  caxis([min -15])
  xlabel('Time (s)')
  ylabel('Frequency (Hz)')

  A = get(gca,'position');
  A(1,1) = A(1,1) * 0.5;  # x pos
  A(1,2) = A(1,2) * 0.8;  # y pos
  A(1,3) = A(1,3) * 1.2;  # horizontal size
  A(1,4) = A(1,4) * 1.7;  # vertical size
  set(gca,'position',A);


  ### Spectogram sub ###
  subplot(plot_rows, plot_cols, 4)
  imagesc (t, f, S);
  title(sprintf('G%d spectogram raw ADC sub %d Hz',i, SUB_HZ/2),"fontsize", 16)
  axis xy
  #colormap(jet)
  colorbar
  caxis([min -15])
  xlabel('Time (s)')
  ylabel('Frequency (Hz)')
  ylim([0 SUB_HZ/2])

  A = get(gca,'position');
  A(1,1) = A(1,1) * 0.5;  # x pos
  A(1,2) = A(1,2) * 0.45; # y pos
  A(1,3) = A(1,3) * 1.2;  # horizontal size
  A(1,4) = A(1,4) * 1.7;  # vertical size
  set(gca,'position',A);
end
