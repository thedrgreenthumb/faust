//Description
//ECHO processor


import("music.lib");
import("effect.lib");

import("rectangles.lib");

//Controls
pp_reps_num = hslider("Number of reps", 4, 0, 12, 1);
pp_reps_time = hslider("Time ms", 100, 50, 1000, 10);
pp_reps_rate = hslider("Reps Step", 20, 10, 100, 5);
pp_reps_distr = hslider("Res Distr", 0, 0, 4, 0.05);
pp_rev = hslider("reverb", 0.5, 0, 1, 0.05);
pp_lf = hslider("LF", 0.5, 0, 1, 0.05);
pp_hf = hslider("HF", 0.5, 0, 1, 0.05);
pp_reps_vol = hslider("Reps Volume", 0.5, 0, 1, 0.05);



N = 12;
flo_delay = fdelay2s;

taps_distr0 = (1,0.9,0.85,0.8,0.75,0.7,0.65,0.6,0.55,0.5,0.45,0.4); //incr_saw_tooth
taps_distr1 = (0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,1); //decr_saw_tooth

taps_sw_step = (N/pp_reps_num):int;

//Reverb
reverb(mix) = _<:(schoeders2(0.7, 0.25, 0.7, 1000):lowpass(2,4000):_*0.5),_:mix2(1 - mix):_;	

process = _<:_,(par(i, N, flo_delay(get_delay_length(pp_reps_time)+i*get_delay_length(pp_reps_rate))):
			par(i,N,_*pp_reps_vol):
			par(i,N,_*(pp_reps_num <= i))<:
			par(i,N,_*take(i+1,taps_distr0)),par(i,N,_*take(i+1,taps_distr1)):
			interleave(12,2):par(i,N,mix2(pp_reps_distr)):>reverb(pp_rev):coloration_filter2(pp_lf,pp_hf)):>_;



