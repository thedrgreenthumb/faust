//Name: delay02

//Description
//Delay plugin.
//Consists of delay ping-pong strucutre, and additional stuff, 
//like coloration filter and reverberator.
//version 0.2

import("music.lib");
import("effect.lib");

import("rectangles.lib");

//Controls
pp_time = hslider("Time ms", 500, 50, 2000, 10);
pp_fb = hslider("feedback", 0.3, 0, 1, 0.05);
pp_pp = hslider("ping-pong", 0.3, 0, 1, 0.05);
pp_rev = hslider("reverb", 0.5, 0, 1, 0.05);
pp_lf = hslider("LF", 0.5, 0, 1, 0.05);
pp_hf = hslider("HF", 0.5, 0, 1, 0.05);
p_duck = hslider("ducking", 0, 0, 1, 0.05);
p_dw = hslider("dry/wet", 0.5, 0, 1, 0.05);

//Controls colibration
p_time = pp_time:smooth(tau2pole(0.5));
p_fb = pp_fb;
p_pp = pp_pp:_*0.5:_+0.5;
p_rev = pp_rev:_*0.6;
p_lf = pp_lf:_-0.5:_*2;
p_hf = pp_hf:_-0.5:_*2;

//Ping-Pong delay implementation
pp_delay(time,fb_coef,pp_fb_coef) = _,_*(1 - pp_fb_coef):
	(_,X,_:(X:(pp_fb_delay(time, fb_coef,pp_fb_coef))),
	(X:(pp_fb_delay(time, fb_coef,pp_fb_coef))):_,_)~X
	:>_,_
	with {
		flo_delay = fdelay2s; //2 seconds max
		pp_fb_delay(time,fb_coef,pp_fb_coef) = _+_*pp_fb_coef:
		(_+_:flo_delay(get_delay_length(time)))~_*fb_coef;
	};
	
//Reverb
reverb(mix) = _<:(schoeders2(0.7, 0.25, 0.7, 1000):lowpass(2,4000):_*0.5),_:mix2(1 - mix):_;	
	
//Duck switcher
duck_sw(val) = _,_:(_<:_,duck_switcher(0.05, 0.1, val*44:db2linear)),_:_,_*_:_,_;
	
process = _,_<:(_,pp_delay(p_time,p_fb*(1 - p_pp),p_pp*p_fb),_):
			(_,(reverb(p_rev):coloration_filter2(p_lf,p_hf)),(reverb(p_rev):coloration_filter2(p_lf,p_hf)),_):
			_,_,X:
			duck_sw(p_duck),duck_sw(p_duck):mix2(p_dw),mix2(p_dw);

