declare id  	"parametric pitch shifter";
declare name "Parametric pitch shifter";
declare category "Modulation";

//------------------------------------
//Based at:
//----
//------------------------------------

//------------------------------------
//Description:
// Pitch shifter from faust examples combined with own parametric controller.
//Parameters description:
//envelope - input signal  time parameter 
//speed - frequency of parametric controller oscillator
//depth - depth of oscillator and envelope follower signals
//control - mixing between follower and oscillator segnals
//shift - signal shifting in semitones
//dry/wet - ...
//------------------------------------

import("music.lib");
import("effect.lib");

//Constrols
envelope = hslider("envelope", 1, 0.1,3, 0.05);
speed = hslider("speed", 0.1, 0.1, 10, 0.05);
depth = hslider("depth", 0, 0, 1, 0.05);
control = hslider("control",0.5, 0, 1, 0.05);
shift = hslider("shift", 0, -6, +6, 0.1)*2; //*2 needed to conform with parametric controller output
dry_wet = hslider("dry/wet", 0.5, 0,1, 0.05);

//Can be add to .lib
mixer(mix) = _*(1 - mix),_*mix:>_;

//Parametric controller, combinate signals from envelope follower and oscillator, can be added to .lib
c_folower_colibration = 6;
parametric_controller(mix, envelope_t, freq, depth) = (amp_follower(envelope_t):_*c_folower_colibration:_*depth,osc(freq)*0.5:_,_*depth):mixer(mix):_+0.5; 

//PS constants, can be changed to decrease effect delay 
c_samples = 2048;
c_xfade   = 1024;
//PS implementation, copy-pasted from faust repository, see ./examples/pitch_shifter.dsp
transpose (w, x, s, sig)  =
	fdelay1s(d,sig)*fmin(d/x,1) + fdelay1s(d+w,sig)*(1-fmin(d/x,1))
	   	with {
			i = 1 - pow(2, s/12);
			d = i : (+ : +(w) : fmod(_,w)) ~ _;
	        };

process = _<:_,(_<:parametric_controller(control, envelope, speed, depth)*shift,_:transpose(c_samples,c_xfade)):mixer(dry_wet);
