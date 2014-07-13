//Delay with flanger
//Stereo
//Need to impruve wah sensivity

import("geometry.lib");

//Controls
p_time = hslider("Time ms", 500, 50, 2000, 10):smooth(tau2pole(0.05));
p_fb = hslider("feedback", 0.3, 0, 1, 0.05);
p_fl = hslider("Flange", 0.3, 0, 1, 0.05);
p_dw = hslider("dry/wet", 0.5, 0, 1, 0.05);



flanger(lfo,depth) =_<:_,(-:fdelay(samps_max,((lfo+1)/2)*depth*0.9*samps_max))~*(0.5):_,*(-1) : + : *(0.5)
with {
	samps_max = 2048; //SR=48000
};

process = _,_<:_,pp_delay(p_time,p_fb,0.2,_,_),_:
	_,flanger(osc(1000/p_time),p_fl),flanger(osc(1000/p_time)*-1,p_fl),_:
	mix2(p_dw),mix2(1 - p_dw);
