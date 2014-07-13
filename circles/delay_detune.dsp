//Delay with detune
//Stereo
//Need to impruve wah sensivity

import("geometry.lib");

//Controls
p_time = hslider("Time ms", 500, 50, 2000, 10):smooth(tau2pole(0.05));
p_fb = hslider("feedback", 0.3, 0, 1, 0.05);
p_dt = hslider("Detune", 0.3, 0, 1, 0.05);
p_dw = hslider("dry/wet", 0.5, 0, 1, 0.05);

process = _,_<:_,pp_delay(p_time,p_fb,0.2,_,_),_:
	_,detune(osc(1000/p_time),p_dt),detune(osc(1000/p_time),p_dt),_:
	mix2(p_dw),mix2(1 - p_dw);



