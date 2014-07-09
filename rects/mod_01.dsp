	//Description
//Write something!!!

import("music.lib");
import("effect.lib");

import("rectangles.lib");


pp_freq = hslider("freq", 5, 0.1, 20, 0.1);
pp_freq1 = hslider("freq1", 600, 300, 2100, 10);
pp_form = hslider("form", 0, 0, 4, 0.05);
pp_depth = hslider("depth", 0.5, 0, 1, 0.05);

pp_phaser = hslider("phaser", 2, 1.5, 4, 0.05);


//Pseudo random noise oscillator
pr_noise4(freq) = (osc(freq):fdelay1s(oscb(0.21*freq):_+1:_*0.5)),
				  (osc(0.91*freq):fdelay1s(lf_sawpos(0.35*freq))),
				  (osc(0.73*freq):@(212)),
				  (osc(0.57*freq):fdelay1s(oscb(0.87*freq):_+1:_*0.5)):>_*0.5:_;

// ---- experimentall stuff
osc_combo1(freq, form) = (osc(freq),saw1(freq),lf_squarewave(freq),(saw1(freq):_*-1),(pr_noise4(freq):_*0.5)):par(i,5,_*0.5):
	mix5(form):lowpass(4,50);

tremolo(lfo, depth) = _:(lfo * depth + depth - 1),_:_*_:_;  
auto_wah(lfo,depth) = wah4(lfo:_+1:_*0.5:_*4000:_*depth:_+300);
// ---- phaser impl
ap_series_mono(sections,phase01,fb,frqmin,fratio,frqmax,osc_lfo,width) =
 (+ : seq(i,sections,ap2p(R,th(i)))) ~ *(fb)
with {
     tf2 = component("filter.lib").tf2;
     // second-order resonant digital allpass given pole radius and angle:
     ap2p(R,th) = tf2(a2,a1,1,a1,a2) with {
       a2 = R^2;
       a1 = -2*R*cos(th);
     };
     SR = component("music.lib").SR;
     R = exp(-pi*width/SR);
     lfo = (1+osc_lfo)/2; // in [0,1]
     pi = 4*atan(1);
     thmin = 2*pi*frqmin/SR;
     thmax = 2*pi*frqmax/SR;
     th1 = thmin + (thmax-thmin)*lfo;
     th(i) = (fratio^(i+1))*th1;
};

phaser_imp(lfo,depth) = 
      _ <: *(g1) + g2mi*ap_series_mono(4,0,0,300,2.5,3000,lfo,2500)
with {               // depth=0 => direct-signal only
     g1 = 1-depth/2; // depth=1 => phaser mode (equal sum of direct and allpass-chain)
     g2 = depth/2;   // depth=2 => vibrato mode (allpass-chain signal only)
     g2mi = select2(0,g2,-g2); // inversion negates the allpass-chain signal
};
// ---- phaser impl
detune(lfo,depth) = fdelay1s(((lfo+1)*0.5)*depth*samps_max)
with {
	samps_max = 400; //SR=48000
};
flange(lfo,depth,fb) = flanger_mono(samps_max,((lfo+1)*0.5)*depth*samps_max,depth,fb,0)
with {
	samps_max = 512;
};
chorus(lfo,depth,fb) = _<:flange(lfo,depth,fb*0.3),flange(lfo:fdelay1s(osc(3):_+1:_*0.5:_*200):_*-1,depth,fb*0.7):>_;
trichor(lfo,depth,fb) = _<:flange(lfo,depth,fb*0.3),
						flange(lfo:fdelay1s(osc(3):_+1:_*0.5:_*200):_*-1,depth,fb*0.7),
						flange(lfo:fdelay1s(lf_sawpos(0.78*lfo):_+1:_*0.5:_*200),depth,fb*0.5)
						:>_;
rotary(speed,depth) = _*0.5+_*0.5<:
(fdelay(500, depth*(osc(speed)+1)*0.5)*(1-osc(speed)),
fdelay(500,depth*((osc(speed))+1)*0.5)*(1+osc(speed)):
_,_<:
_,_,_,_:_+_*0.7,_+_*0.7);

//process = osc_combo1(pp_freq,pp_form);
//process = tremolo(osc_combo1(pp_freq,pp_form),pp_depth);
//process = auto_wah(osc_combo1(pp_freq,pp_form),pp_depth);
//process = phaser_imp(osc_combo1(pp_freq,pp_form),pp_depth);
//process = detune(osc_combo1(pp_freq,pp_form),pp_depth);
//process = flange(osc_combo1(pp_freq,pp_form),pp_depth,0.8);
//!!!
//process = chorus(osc_combo1(pp_freq,pp_form),pp_depth,1);
//process = trichor(osc_combo1(pp_freq,pp_form),pp_depth,1);
process = rotary(5,0.7);
