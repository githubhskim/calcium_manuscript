/*For macros used in this code, please refer to cohortdocs on the Channing website. 
For more information, please visit https://www.nurseshealthstudy.org/researchers (contact e-mail: nhsaccess@channing.harvard.edu) */

%include "./variables.sas";
/*for total calcium intake*/
data nhs2all;
set nhs2;
run;

data nhs2lt50;
	set nhs2;
	where ageyr<50 ; 
run;

data nhs2lt55;
	set nhs2;
	where ageyr<55 ; 
run;


data nhs2ge50;
	set nhs2;
	where ageyr>=50 ;
run;

data nhs2normalbmi;
	set nhs2;
	where 0<bmicum<25 ;
run;

data nhs2overbmi;
	set nhs2;
	where bmicum>=25 ;
run;

/* Table 2. Total calcium intake and risk of colorectal cancer (all), NHS II 1991-2015 */
	%cox(nhs2all,        dt_colorectal, t_colorectal,  calccumq,  calccum_cont,  calccumtrd,  calccumtrd1, 4);
	/* MPGREG9 will append the outdat to the dataset, so you need to manually delete those datasets before output the same name dataset */
	proc datasets;
		delete  calccumq;
	quit;
	proc datasets;
		change result=calciumall;
	quit;

/* Table 3. Subgroup analyses: colon (proximal vs distal) vs rectal */
	%cox(nhs2all,        dt_prox, t_prox, calccumq, calccum_cont, calccumtrd, calccumtrd1, 4);
	/* MPGREG9 will append the outdat to the dataset, so you need to manually delete those datasets before output the same name dataset */
	proc datasets;
		delete calccumq;
	quit;
	%cox(nhs2all,        dt_distal, t_distal, calccumq, calccum_cont, calccumtrd, calccumtrd1, 4);
	/* MPGREG9 will append the outdat to the dataset, so you need to manually delete those datasets before output the same name dataset */
	proc datasets;
		delete calccumq;
	quit;
	%cox(nhs2all,        dt_rectalcancer, t_rectalcancer, calccumq, calccum_cont, calccumtrd, calccumtrd1, 4);
	/* MPGREG9 will append the outdat to the dataset, so you need to manually delete those datasets before output the same name dataset */
	proc datasets;
		delete calccumq;
	quit;

	proc datasets;
		change result=allsubsite;
	quit;

/*dietary calcium*/
/*dietary calcium and risk of colorectal cancer, NHS II 1991-2015 */
	%cox(nhs2all,        dt_colorectal, t_colorectal, diet_calc3cumq, diet_calc3cum_cont, diet_calc3cumtrd, diet_calc3cumtrd1, 3);
	/* MPGREG9 will append the outdat to the dataset, so you need to manually delete those datasets before output the same name dataset */
	proc datasets;
		delete diet_calc3cumq;
	quit;

	proc datasets;
		change result=dietary;
	quit;
/*supplementary calcium*/
/*supplementary calcium and risk of colorectal cancer, NHS II 1991-2015 */
	%cox(nhs2all,        dt_colorectal, t_colorectal, supp_calc3cumt, supp_calc3cum_cont, supp_calc3cumtrd, supp_calc3cumtrd1, 3);
	/* MPGREG9 will append the outdat to the dataset, so you need to manually delete those datasets before output the same name dataset */
	proc datasets;
		delete supp_calc3cumt;
	quit;

	proc datasets;
		change result=supplementary;
	quit;
/*dairy calcium*/
/*dairy calcium and risk of colorectal cancer, NHS II 1991-2015 */
	%cox(nhs2all,        dt_colorectal, t_colorectal, dcalc3cumq, dcalc3cum_cont, dcalc3cumtrd, dcalc3cumtrd1, 3);
	/* MPGREG9 will append the outdat to the dataset, so you need to manually delete those datasets before output the same name dataset */
	proc datasets;
		delete dcalc3cumq;
	quit;

	proc datasets;
		change result=dairy;
	quit;
/*non-dairy dietary calcium*/
/*non-dairy dietary calcium and risk of colorectal cancer, NHS II 1991-2015 */
	%cox(nhs2all,        dt_colorectal, t_colorectal, nddcumq, nddcum_cont, nddcumtrd, nddcumtrd1, 3);
	/* MPGREG9 will append the outdat to the dataset, so you need to manually delete those datasets before output the same name dataset */
	proc datasets;
		delete nddcumq;
	quit;

	proc datasets;
		change result=ndd;
	quit;

	
/* Total calcium intake and risk of early-onset (age<50) colorectal cancer, NHS II 1991-2015 */
	%cox(nhs2lt50,        dt_CRC50, t_CRC50,  calccumq,  calccum_cont,  calccumtrd,  calccumtrd1, 4);
	/* MPGREG9 will append the outdat to the dataset, so you need to manually delete those datasets before output the same name dataset */
	proc datasets;
		delete  calccumq;
	quit;
	proc datasets;
		change result=eocrc;
	quit;

/* Total calcium intake and risk of early-onset (age<55) colorectal cancer, NHS II 1991-2015 */
	%cox(nhs2lt55,        dt_CRC55, t_CRC55,  calccumq,  calccum_cont,  calccumtrd,  calccumtrd1, 4);
	/* MPGREG9 will append the outdat to the dataset, so you need to manually delete those datasets before output the same name dataset */
	proc datasets;
		delete  calccumq;
	quit;
	proc datasets;
		change result=eocrc55;
	quit;
		
		
/* Total calcium intake and risk of late-onset (age>=50) colorectal cancer, NHS II 1991-2015 */
	%cox(nhs2all,        dt_CRCge50, t_CRCge50, calccumq, calccum_cont, calccumtrd, calccumtrd1, 4);
	/* MPGREG9 will append the outdat to the dataset, so you need to manually delete those datasets before output the same name dataset */
	proc datasets;
		delete calccumq;
	quit;
	proc datasets;
		change result=locrc;
	quit;

/* Subgroup analyses by BMI */
	%cox(nhs2normalbmi,      dt_colorectal, t_colorectal, calccumq, calccum_cont, calccumtrd, calccumtrd1, 4);
	/* MPGREG9 will append the outdat to the dataset, so you need to manually delete those datasets before output the same name dataset */
	proc datasets;
		delete calccumq;
	quit;
	%cox(nhs2overbmi,        dt_colorectal, t_colorectal, calccumq, calccum_cont, calccumtrd, calccumtrd1, 4);
	/* MPGREG9 will append the outdat to the dataset, so you need to manually delete those datasets before output the same name dataset */
	proc datasets;
		delete calccumq;
	quit;
	proc datasets;
		change result=bmisubgroup;
	quit;


/*Print*/
	proc means data=nhs2all n nmiss min max mean std median p5 p25 p75 p95;
		class calccumq;
		var calccum;
	run;

	proc print data=calciumall noobs; run;

	proc means data=nhs2all n nmiss min max mean std median p5 p25 p75 p95;
		class calccumq;
		var calccum;
	run;

	proc print data=allsubsite noobs; run;

	proc means data=nhs2all n nmiss min max mean std median p5 p25 p75 p95;
		class diet_calc3cumq;
		var diet_calc3cum;
	run;
	
	proc print data=dietary noobs; run;

	proc means data=nhs2all n nmiss min max mean std median p5 p25 p75 p95;
		class supp_calc3cumt;
		var supp_calc3cum;
	run;
	
	proc print data=supplementary noobs; run;

	proc means data=nhs2all n nmiss min max mean std median p5 p25 p75 p95;
		class dcalc3cumq;
		var dcalc3cum;
	run;
	
	proc print data=dairy noobs; run;

	proc means data=nhs2all n nmiss min max mean std median p5 p25 p75 p95;
		class nddcumq;
		var nddcum;
	run;
	
	proc print data=ndd noobs; run;

	proc means data=nhs2lt50 n nmiss min max mean std median p5 p25 p75 p95;
		class calccumq;
		var calccum;
	run;

	proc print data=eocrc noobs; run;

	proc means data=nhs2lt55 n nmiss min max mean std median p5 p25 p75 p95;
		class calccumq;
		var calccum;
	run;

	proc print data=eocrc55 noobs; run;

	proc means data=nhs2ge50 n nmiss min max mean std median p5 p25 p75 p95;
		class calccumq;
		var calccum;
	run;

	proc print data=locrc noobs; run;

	proc print data=bmisubgroup noobs; run;


