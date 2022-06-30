clear ; close all; clc
pkg load signal

data = csvread('timing.log');
data = csvread('timing-fixed.log');
SAMPLE_RATE_HZ = length(data)/((data(end,end)-data(1,end))/168e6);
data_rows = diff(data);  # rows diff
data_cols = diff(data,1,2); # cols diff


#data = data(:,4)-data(:,1);

NAMES_ROWS = {'start->start','a->a', 'b->b', 'c->c','d->d','e->e','f->f','end->end'};
NAMES_COLS = {'start->a','a->b', 'b->c', 'c->d','d->e','e->f','f->end'};

# pwelch
overlap = 0.5;
window = hann(1024);

# spectogram
win = 64;

figure
for i = 1:8
  x = data_cols(:,i) / 168;
  xx = [1:1:length(x)]/SAMPLE_RATE_HZ;
  
  subplot(4, 2, i);
  plot(xx,x);
  title(sprintf('%s',NAMES_COLS{i}), "fontsize", 16);
  xlabel('Time (s)');
  ylabel('Duration (us)');
end

plot_rows = 2;
plot_cols = 1;

for i = 1:8
  figure
  ### pwelch ###
  x = data_rows(:,i);
  [Pyy,Fy] = pwelch(x,window,overlap,length(x),SAMPLE_RATE_HZ);
  Pyy = 10*log10(Pyy);
  
  ### Spectrum full ###
  subplot(plot_rows, plot_cols, 1)
  hold on
  plot(Fy,Pyy);
  hold off
  grid on
  box on
  title(sprintf('%s @ %d Hz',NAMES_ROWS{i},SAMPLE_RATE_HZ), "fontsize", 16)
  xlabel('Frequency (Hz)')
  ylabel('PSD (dB/Hz)')
  xticks(0:10:SAMPLE_RATE_HZ)
  #legend(sprintf('Raw ADC data @ %d Hz', SAMPLE_RATE_HZ))
  
  
  
  ### Spectogram ###
  [S, f, t] = specgram(x,win,SAMPLE_RATE_HZ);
  S = 1/(SAMPLE_RATE_HZ*win) * abs(S).^2;
  S = 10*log10(S);
  
  
  ### Spectogram full ###
  subplot(plot_rows, plot_cols, 2)
  imagesc (t, f, S);
  #title(sprintf('G%d spectogram raw ADC',i), "fontsize", 16)
  axis xy
  #colormap(jet)
  colorbar
  xlabel('Time (s)')
  ylabel('Frequency (Hz)')
  
end 
