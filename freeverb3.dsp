declare id  	"freeverb3";
declare name "Freeverb3";
declare category "Reverb";

//------------------------------------
//Faust implementation of freeverb3
//------------------------------------

import ("music.lib");

//Controls
max_predelay_ms = 200;
predelay = hslider("predelay ms", 0, 0, max_predelay_ms, 10);
chorus = hslider("chorus", 0.5, 0, 1, 0.01);
definition = hslider("definition",0.5,0,1,0.01):_*0.25;
decay1 = hslider("decay1",0.5,0,1,0.01):_*0.938;
decay2 = hslider("decay2",0.5,0,1,0.01):_*0.844;
decay3 = hslider("decay3",0.5,0,1,0.01):_*0.906;
diffusion1 = hslider("diffusion1",0.5,0,1,0.01):_*0.312;
diffusion2 = hslider("diffusion2",0.5,0,1,0.01):_*0.375;
decay_diffusion = hslider("decay diffusion",0.5,0,1,0.01):_*0.406;
damping = hslider("damping",0.5,0,1,0.01):_*0.312;//1-
hf_bw = hslider("HF BW",0.5,0,1,0.01):_*0.188; //1-
dry_wet = hslider("dry/wet", 0.5, 0, 1, 0.05);

param = hslider("param", 3000, 0, 10000, 0.05);

//Library functions
X = (_,_)<:(!,_,_,!);
opf(a) = (_+_*(1-a)~@(1)*a); 
ozf(b) = _<:(@(1):_*(1-b)),_*b:>_;
mixer(c,x0,y0,x1,y1) = sel(c,x0,y0), sel(c,x1,y1)
	with { 
			sel(c,x,y) = (1-c)*x + c*y; 
		  };

//Nested allpass filter
//n_ap(dt,c1,c2,next) = (_,_ <: (*(c1),_:+:next:@(dt)), (_*c2,_:-)) ~ _ : (!,_); 
n_ap(dt,c1,c2,next) = (_+_<:(next:@(dt)),_*-c1)~_*c1:_*c2,_:>_;

//Algorithm functions
left_branch = (opf(hf_bw):@(1):_*0.5),(_<:((opf(0.875):_*0.156),_*0.344)):>opf(damping):
	n_ap(239,diffusion2,decay2,_):@(2):n_ap(392,diffusion1,decay3,_)<:@(1055),_:
	n_ap(612,decay_diffusion,decay2,n_ap(1944,definition,decay1,_)),_:@(344),_:
	n_ap(1264,decay_diffusion,decay2,n_ap(816,definition,decay1,n_ap(1212,definition,0.938,@(121):ozf(chorus*0.781)))),_:@(1572),_;

right_branch = (opf(hf_bw):@(1):_*0.5),(_<:((opf(0.875):_*0.156),_*0.344)):>opf(damping):
	n_ap(205,diffusion2,decay2,_):@(1):n_ap(329,diffusion1,decay3,_)<:@(625),_:@(835),_:
	n_ap(368,decay_diffusion,decay2,n_ap(2032,definition,decay1,_)),_:@(500),_:
	n_ap(1340,decay_diffusion,decay2,n_ap(688,definition,decay1,n_ap(1452,definition,0.938,@(5):ozf(chorus*0.188)))),_:@(16),_;

freeverb3 = _,_:(_,X,_:(X:left_branch),(X:right_branch):_,X,_)~X:>_,_;

//Correct delay lines according sample rate
get_predelay_length(x) = x*SR:_*0.001;

process = freeverb3;


