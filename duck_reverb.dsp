declare id   "duckDelay";
declare name "Duck Delay";
declare category "Echo/Delay";

//------------------------------------
//Inspired by:
//http://www.gvst.co.uk/gduckdly.htm
//Axe-FX II Owner's manual:5.6
//------------------------------------

import("music.lib");
import("effect.lib");

//Constrols
p_attack_time = hslider("attack time s", 0.1, 0.05, 0.5, 0.05);
p_release_time = hslider("relese time s", 0.1, 0.05, 2, 0.05);
p_amount = hslider("amount db", 0.5, 0,56, 0.05):db2linear;

//Consts
c_channels_sw_time = 0.1;
c_fdelay_max_len = 393216;

get_delay_length(x) = x*SR:_*0.001;

//Import reverb unit
rev = component("freeverb.dspi");
process = _<:_,(_<:(_:rev),		
	(amp_follower_ud(p_attack_time,p_release_time):_*p_amount:_>1:(1 - _):
	smooth(tau2pole(c_channels_sw_time)))):_,_*_
	:>_;
