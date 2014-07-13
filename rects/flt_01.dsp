//Description

import("effect.lib");
import("rectangles.lib");

//Controls
pp_flt = hslider("Flt type", 0, 0, 3, 0.05);
pp_freq = hslider("Freq Hz", 440, 50, 4000, 10);
pp_q = hslider("Q factor", 0.707, 0.3, 1, 0.05);
pp_lfo = hslider("LFO mode", 0, 0, 4,0.05);
pp_speed = hslider("speed", 0.1, 0.1, 10, 0.05);
pp_depth = hslider("depth", 0, 0, 1, 0.05);
pp_envelope = hslider("envelope", 1, 0.1,3, 0.05);
pp_control = hslider("control",0.5, 0, 1, 0.05);

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


//Parametric controller, combinate signals from envelope follower and oscillator, can be added to .lib
//c_folower_colibration = 6;
//parametric_controller(mix, envelope_t, freq, depth) = (amp_follower(envelope_t):_*c_folower_colibration:_*depth,osc(freq)*0.5:_,_*depth):mixer(mix):_+0.5;

//process = _<:moog_vcf_2b(0.707,500),phaser_imp(10,20),notchw(100,500),fb_fcomb(65536,100,0.7,0.3):mix4(0.5);
//---------------------------
trichor(lfo,depth,fb) = _<:flange(lfo,depth,fb*0.3),
						flange(lfo:fdelay1s(osc(3):_+1:_*0.5:_*200):_*-1,depth,fb*0.7),
						flange(lfo:fdelay1s(lf_sawpos(0.78*lfo):_+1:_*0.5:_*200),depth,fb*0.5)
						:>_;

flange(lfo,depth,fb) = flanger_mono(samps_max,((lfo+1)*0.5)*depth*samps_max,depth,fb,0)
with {
	samps_max = 512;
};

process = trichor(pp_flt,pp_q,pp_depth);
