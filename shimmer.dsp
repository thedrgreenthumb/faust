declare id   "shimmer";
declare name "Shimmer";
declare category "Reverb";

//------------------------------------
//Based on:
//ValhallaShimmer
//------------------------------------

import ("music.lib");
import("filter.lib");
import("effect.lib");

//Constrols
//PS controls
envelope = hslider("envelope", 1, 0.1,3, 0.05);//parametric_controller(control, envelope, speed, depth)*shift
speed = hslider("speed", 0.1, 0.1, 10, 0.05);
depth = hslider("depth", 0, 0, 1, 0.05);
control = hslider("control",0.5, 0, 1, 0.05);
shift = hslider("shift", 0, -6, +6, 0.1)*2; //*2 needed to conform with parametric controller output
//Reverb controls
size = hslider("size", 0.1, 1, 3, 0.05);
diffusion =  hslider("diffusion", 0.5, 0.1, 0.7, 0.05);
feedback =  hslider("feedback", 0, 0, 0.35, 0.05);
hf_damping = hslider("hf damping", 0, 0.005, 0.995, 0.005);
//Global 
dry_wet = hslider("dry/wet", 0.5, 0, 1, 0.05);

//Can be add to .lib
mixer(mix) = _*(1 - mix),_*mix:>_;

//Parametric controller, combinate signals from envelope follower and oscillator, can be added to .lib
c_folower_colibration = 6;
parametric_controller(mix, envelope_t, freq, depth) = (amp_follower(envelope_t):_*c_folower_colibration:_*depth,osc(freq)*0.5:_,_*depth):mixer(mix):_+0.5;

//Can be moved to .lib too
X = (_,_)<:(!,_,_,!);
opf(a) = (_+_*(1-a)~@(1)*a); 
allpass_with_fdelay(dt1,coef,dt2,dt2pos) = (_,_ <: (*(coef),_:+:@(dt1):fdelay(dt2,dt2pos)), -) ~ _ : (!,_);
allpass(dt,fb) = (_,_ <: (*(fb),_:+:@(dt)), -) ~ _ : (!,_);
dry_wet_mixer(c,x0,y0,x1,y1) = sel(c,x0,y0), sel(c,x1,y1)
	with { 
			sel(c,x,y) = (1-c)*x + c*y; 
		 };

APFB(dt1,fb1,dtv,dtvpos,dt2,fb2) = _:allpass_with_fdelay(dt1,fb1,dtv,dtvpos):allpass(dt2,fb2);

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

process(x,y) = x,y:(_,_:
	(_,X,_:(
	(_*feedback+_*0.3:>APFB(601*size,0.7*diffusion,50,49*(osc(1)+1)/2,613*size,0.75*diffusion):opf(hf_damping)),
    (_*feedback+_*0.3:>APFB(2043*size,0.75*diffusion,50,49*(osc(1.5)+1)/2,2087*size,0.75*diffusion):opf(hf_damping))
	):X)~(
	(_*feedback:dcblockerat(80)
	:@(4325):
	APFB(2337*size,0.7*diffusion,50,49*(osc(0.7)+1)/2 ,2377*size,0.4*diffusion):@(2969):transpose(c_samples,c_xfade,	 
    (x:parametric_controller(control, envelope, speed, depth):_*shift))),
	(_*feedback:dcblockerat(80)
	:@(4763):
	APFB(1087*size,0.7*diffusion,50,49*(osc(1.3)+1)/2,1113*size,0.4*diffusion):@(3111):transpose(c_samples,c_xfade,	 			   
	(y:parametric_controller(control, envelope, speed, depth):_*shift)))))
	:dry_wet_mixer(dry_wet,x,_,y,_);





