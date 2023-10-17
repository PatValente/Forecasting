cas;
caslib _all_ assign;

proc sort data=public.total_load_temp out=tot_load_temp;
	by zone_id date;
run;

/*transpose the H values*/
PROC TRANSPOSE DATA=tot_load_temp OUT=casuser.h;
	VAR h1-h24;
	BY zone_id date;
RUN;

/*strip out the H from Hours values and convert date to datetime*/
data casuser.h(drop=col1);
	set casuser.h;
	hour=compress(_name_, 'h');
	datetime=dhms(date, hour, 00, 00);
	format datetime datetime.;
	h=col1;
run;

/*Do the same for the T values. Transpose*/
PROC TRANSPOSE DATA=tot_load_temp OUT=casuser.t;
	VAR t1-t24;
	BY zone_id date;
RUN;

/*strip out the T from Hours values and convert date to datetime*/
data casuser.t(drop=col1);
	set casuser.t;
	hour=compress(_name_, 't');
	datetime=dhms(date, hour, 00, 00);
	format datetime datetime.;
	t=col1;
run;

/*merge the new transposed data sets, H and T*/
data public.patfor;
	merge casuser.h casuser.t;
	by zone_id datetime;
run;

/*promote the table in public for use in Visual Forecasting and etc.*/
proc casutil outcaslib="public";
	promote casdata="patfor" incaslib="public";
	*save casdata =                 "patfor" incaslib="public";
run;

quit;
