import("music.lib");
import("filter.lib");

//Based at:
//U. Zolzers DAFX book

dry_wet = hslider("dry/wet", 0.5, 0, 1, 0.05);
speed = hslider("freq", 30, 1, 60, 1);
depth = hslider("depth", 50, 10, 200, 1);
coloration = hslider("coloration", 0, -1, 1, 0.05);

X = (_,_)<:(!,_,_,!);

coloration_filter(coloration) = _<:(low_shelf5((1 - coloration)*12,440),high_shelf5(coloration*12,880)):>_*db2linear(-15);

process = _*0.5+_*0.5<:
	(fdelay(500, depth*(osc(speed)+1)*0.5)*(1-osc(speed)),
	fdelay(500,depth*((osc(speed))+1)*0.5)*(1+osc(speed)):
	coloration_filter(coloration),
	coloration_filter(coloration)<:
	_,_,_,_:_+_*0.7,_+_*0.7);