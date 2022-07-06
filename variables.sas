/*For macros used in this code, please refer to cohortdocs on the Channing website. 
For more information, please visit https://www.nurseshealthstudy.org/researchers (contact e-mail: nhsaccess@channing.harvard.edu) */


/*For NHS Project; 
Here, obtain necessary NHS files and macros*/

/* Create global macro variable date */
data _null_;
	date10=put(date(),yymmdd10.);
	call symput("date",translate(date10,"_","-"));
run;

/* Record start time */
%let _timer_start = %sysfunc(datetime());

/*** Cancer file, aka case file ***/
/*Here, obtain NHS cancer file*/

colorectal=colorect;
dtdxca = dxmonth;
dtdxcrc=dtdxca;

if colon=1 then
coloncancer=1;
if rectum=1 then
rectalcancer=1;
run;

/*duplicate removal*/
proc sort data=cancer nodupkey;
	by id;
run;

/*** Death File ***/
/*Here, obtain NHS death file*/
	dtdth=.;
	if deadmonth> 0 then dtdth=deadmonth;
	if dtdth=. then delete;
	keep id dtdth;
run;

proc sort data=deadff;
	by id;
run;

/*** Main Exposure ***/

/* NTS(Raw) */
%n91_nts(keep=id calor91n alco91n vitd91n vitd_91n calc91n calc_91n);
%n95_nts(keep=id calor95n alco95n vitd95n vitd_95n calc95n calc_95n);
%n99_nts(keep=id calor99n alco99n vitd99n vitd_99n calc99n calc_99n);
%n03_nts(keep=id calor03n alco03n vitd03n vitd_03n calc03n calc_03n);
%n07_nts(keep=id calor07n alco07n vitd07n vitd_07n calc07n calc_07n);
%n11_nts(keep=id calor11n alco11n vitd11n vitd_11n calc11n calc_11n);

/* Folate, Fiber, Calcium, Vitamin D */
%n91_ant(keep=id fol91a   aofib91a calc91a dcalc91a calc_91a vitd91a vitd_91a dvitd91a);
%n95_ant(keep=id fol95a   aofib95a calc95a dcalc95a calc_95a vitd95a vitd_95a dvitd95a);
%n99_ant(keep=id fol9899a aofib99a calc99a dcalc99a calc_99a vitd99a vitd_99a dvitd99a);
%n03_ant(keep=id fol9803a aofib03a calc03a dcalc03a calc_03a vitd03a vitd_03a dvitd03a);
%n07_ant(keep=id fol9807a aofib07a calc07a dcalc07a calc_07a vitd07a vitd_07a dvitd07a);
%n11_ant(keep=id fol9811a aofib11a calc11a dcalc11a calc_11a vitd11a vitd_11a dvitd11a);

data calciumdata;
	merge
		n91_nts n95_nts n99_nts n03_nts n07_nts n11_nts 
		n91_ant n95_ant n99_ant n03_ant n07_ant n11_ant;
	by id;
	
	/* NTS, Raw file */
	array vitdna      {*} vitd91n       vitd95n       vitd99n       vitd03n       vitd07n       vitd11n;
	array vitdn_a     {*} vitd_91n      vitd_95n      vitd_99n      vitd_03n      vitd_07n      vitd_11n;
	
	array calcna      {*} calc91n       calc95n       calc99n       calc03n       calc07n       calc11n;
	array calcn_a     {*} calc_91n      calc_95n      calc_99n      calc_03n      calc_07n      calc_11n;
	
	/* ANT, antilog transformed */
	array vitda       {*} vitd91a       vitd95a       vitd99a       vitd03a       vitd07a       vitd11a;
	array vitd_a      {*} vitd_91a      vitd_95a      vitd_99a      vitd_03a      vitd_07a      vitd_11a;
	
	array calca       {*} calc91a       calc95a       calc99a       calc03a       calc07a       calc11a;
	array calc_a      {*} calc_91a      calc_95a      calc_99a      calc_03a      calc_07a      calc_11a;
	
	/* New variable */
	array supp_vitda  {*} supp_vitd91a  supp_vitd95a  supp_vitd99a  supp_vitd03a  supp_vitd07a  supp_vitd11a;
	array supp_calca  {*} supp_calc91a  supp_calc95a  supp_calc99a  supp_calc03a  supp_calc07a  supp_calc11a;
	
	/*vitD*/
	do i=1 to dim(vitdna);
		/* Calculate supplmental Vitamin D intake */
		supp_vitda{i}=vitda{i}-vitd_a{i};
		/* Mark 0 */
		if vitdna{i}=vitdn_a{i} or supp_vitda{i}<0 then supp_vitda{i}=0;
	end;
	
	/*calcium*/
	do i=1 to dim(calcna);
		/* Calculate supplmental calcium intake */
		supp_calca{i}=calca{i}-calc_a{i};
		/* Mark 0 */
		if calcna{i}=calcn_a{i} or supp_calca{i}<0 then supp_calca{i}=0;
	end;
	
	array aofiba aofib91a aofib95a aofib99a aofib03a aofib07a aofib11a;
	do over aofiba;
		if aofiba in (998, 999) then aofiba=.;
	end;
run;

proc datasets;
	delete 
		n91_nts n95_nts n99_nts n03_nts n07_nts n11_nts 
		n91_ant n95_ant n99_ant n03_ant n07_ant n11_ant;
run;
quit;


/*** Covariates ***/

/******************* Food Intake ***********************************/
%serv91(keep=id  bmix_s91 pmain_s91 bmain_s91 chwi_s91 chwo_s91 turk_s91 dog_s91 bacon_s91 procm_s91 hamb_s91 );
data serv91;
set serv91;
rpmeats91=0;
rpmeats91=sum(bmix_s91, pmain_s91, bmain_s91, procm_s91, bacon_s91, dog_s91, hamb_s91);
run;

%serv95(keep=id  procm_s95 hamb_s95 hambl_s95 bmix_s95 bmain_s95 pmain_s95 chwi_s95 chwo_s95 bacon_s95 bfdog_s95 ctdog_s95);
data serv95;
set serv95;
rpmeats95=0;
rpmeats95=sum(bmix_s95, pmain_s95, bmain_s95, procm_s95, bacon_s95, bfdog_s95, hamb_s95, hambl_s95);
run;
     
%serv99(keep=id bfdog_s99 ctdog_s99 chksa_s99 chwi_s99 chwo_s99 bacon_s99 pmsan_s99 procm_s99 hamb_s99 hambl_s99 bmix_s99 bmain_s99 pmain_s99); 
data serv99;
set serv99;
rpmeats99=0;
rpmeats99=sum(bmix_s99, pmain_s99, bmain_s99, pmsan_s99, procm_s99, bacon_s99, bfdog_s99, hamb_s99, hambl_s99);
run;
              
%serv03(keep=id bfdog_s03 ctdog_s03 chksa_s03 chwi_s03 chwo_s03 bacon_s03 pmsan_s03 procm_s03 hamb_s03 hambl_s03 bmix_s03 bmain_s03 pmain_s03);
data serv03;
set serv03;
rpmeats03=0;
rpmeats03=sum(bmix_s03, pmain_s03, bmain_s03,  pmsan_s03, procm_s03, bacon_s03, bfdog_s03, hamb_s03, hambl_s03);
run;

%serv07(keep=id bfdog_s07 ctdog_s07 chksa_s07 chwi_s07 chwo_s07 bacon_s07 pmsan_s07 procm_s07 hamb_s07 hambl_s07 bmix_s07 bmain_s07 pmain_s07);
data serv07;
set serv07;
rpmeats07=0;
rpmeats07=sum(bmix_s07, pmain_s07, bmain_s07,  pmsan_s07, procm_s07, bacon_s07, bfdog_s07, hamb_s07, hambl_s07);
run;

%serv11(keep=id bfdog_s11 ctdog_s11 chksa_s11 chwi_s11 chwo_s11 bacon_s11 pmsan_s11 procm_s11 hamb_s11 hambl_s11 bmix_s11 bmain_s11 pmain_s11);
data serv11;
set serv11;
rpmeats11=0;
rpmeats11=sum(bmix_s11, pmain_s11, bmain_s11,  pmsan_s11, procm_s11, bacon_s11, bfdog_s11, hamb_s11, hambl_s11);
run;

data nhs2meat;
merge serv91 serv95 serv99 serv03 serv07 serv11;
by id;
keep id 
rpmeats: ;
run;

proc datasets;
delete serv91 serv95 serv99 serv03 serv07 serv11;
run;

/*** Aspirin ***/
/**********************************************************************************************************
%meds8913(keep=id aspf93 aspf95 aspf97 aspf99 aspf01 aspf03 aspf05 aspf07 aspf09 aspf11 aspf13
	nsaif95 nsaif97 nsaif99 nsaif01 nsaif03 nsaif05 nsaif07 nsaif09 nsaif11 nsaif13 );
	run; 
	
/*************regular use of aspirin >=2 days/wk*****************/
data nhs2asp;
set meds8913;

array reguasp{11} aspf93 aspf95 aspf97 aspf99 aspf01 aspf03 aspf05 aspf07 aspf09 aspf11 aspf13;
array regaspre{11} regaspre93 regaspre95 regaspre97 regaspre99 regaspre01 regaspre03 regaspre05 regaspre07 regaspre09 regaspre11 regaspre13;
do i=1 to 11;
	if reguasp{i} in(1,2,3) then regaspre{i}=1; /*less than 2/week*/
	else if reguasp{i} in(4,5,6) then regaspre{i}=2; /*2+/week*/
	else if reguasp{i} in(7,8,9) then regaspre{i}=.; /*unknown*/
	end;	
	
/*non aspirin NSAID coding*/
array ibui{10} nsaif95 nsaif97 nsaif99 nsaif01 nsaif03 nsaif05 nsaif07 nsaif09 nsaif11 nsaif13;
array anyibu{10} regibui95 regibui97 regibui99 regibui01 regibui03 regibui05 regibui07 regibui09 regibui11 regibui13;

do i=1 to 10;
	if ibui{i} in(1,2,3) then anyibu{i}=1;	/*less than 2 days per week*/
	else if ibui{i} in(4,5,6) then anyibu{i}=2;
	else if ibui{i} in(7,8,9) then anyibu{i}=.; 
	end;
run;

data nhs2asp;
set nhs2asp (keep=id
regaspre: 
regibui:);
run;

proc datasets;
delete meds8913;
run;


%der8917(keep=
			 id      birthday height89 corr_ht htm     htcm    age89   age91   age03
			 retmo89 retmo91  retmo93  retmo95 retmo97 retmo99 retmo01 retmo03 retmo05 retmo07 retmo09 retmo11 retmo13 retmo15
			 irt89   irt91    irt93    irt95   irt97   irt99   irt01   irt03   irt05   irt07   irt09   irt11   irt13   irt15
			 nhor89  nhor91   nhor93   nhor95  nhor97  nhor99  nhor01  nhor03  nhor05  nhor07  nhor09  nhor11  nhor13  nhor15
			 bmi18
			 bmi89   bmi91    bmi93    bmi95   bmi97   bmi99   bmi01   bmi03   bmi05   bmi07   bmi09   bmi11   bmi13   bmi15
			 mnpst89 mnpst91  mnpst93  mnpst95 mnpst97 mnpst99 mnpst01 mnpst03 mnpst05 mnpst07 mnpst09 mnpst11 mnpst13 mnpst15
			 smkdr89 smkdr91  smkdr93  smkdr95 smkdr97 smkdr99 smkdr01 smkdr03 smkdr05 smkdr07 smkdr09 smkdr11 smkdr13 smkdr15
			 pkyr89  pkyr91   pkyr93   pkyr95  pkyr97  pkyr99  pkyr01  pkyr03  pkyr05  pkyr07  pkyr09  pkyr11  pkyr13  pkyr15
			 whrat93 whrat05
		);
	
	array ret{*} retmo89 retmo91 retmo93 retmo95 retmo97 retmo99 retmo01 retmo03 retmo05 retmo07 retmo09 retmo11 retmo13 retmo15;
	array irt{*} irt89   irt91   irt93   irt95   irt97   irt99   irt01   irt03   irt05   irt07   irt09   irt11   irt13   irt15;

	do i=1 to dim(irt);
		irt{i}=ret{i}; /* to be consistent with NHS/HPFS */
	end;

	if corr_ht=0 then
		height=.;

	if height89<50 or height89>80 then
		height=.;
	else height=height89;

	if height89>0 then htm=height89*0.0254; /* height has already set outliers in height89 to null */
	else htm=.;

	if htm=. then
		htm=1.65;
	htcm=100*htm;
run;

%nur89(
	keep=
		id      wt1889  wt89    physx89 phexam89 mamm89  mam89  ucol89 icda89
		seuro89 ocauc89 hisp89  scand89 afric89  asian89 oanc89 race
		brcn89  ocan89  mel89   can89   mob89    yob89   pct89  pct589 pct1089
		pct2089 pct3089 age4089 pct4089 hbp89    db89    chol89
		ambrc89 asbrc89 mclc89  fclc89  bclc89   sclc89  mmel89 fmel89
		bmel89  smel89  cafh89  crcfh89 mi89     mdb89   fdb89  bdb89  sdb89 dbfh89
		stndw89 stndh89 sitw89  sith89
	);
	pct4089=age4089;

	if icda89=:563 then
		ucol89=1;
	else ucol89=0;

	if seuro89=1 or ocauc89=1 or scand89=1 then race=1; /* white */
	else race=0; /* nonwhite */

	/* Physical exam */
	phexam89=0;

	if physx89=2 then phexam89=1;  /* Symptom */
	else if physx89=3 then
		phexam89=2; /* Screening */

	/* Mammogram */
	if mamm89=1 then
		mam89=1;
	else mam89=0;

	/* Baseline cancer */
	can89=0;

	if brcn89=1 or ocan89=1 or mel89=1 then
		can89=1;

	/* Family history of Cancer */
	cafh89=0;

	if ambrc89 in (1, 2, 3, 4, 5) then
		cafh89=1;

	if asbrc89 in (1, 2, 3, 4, 5) then
		cafh89=1;

	if sum (mclc89,fclc89, bclc89, sclc89, mmel89,fmel89, bmel89, smel89)>0 then
		cafh89=1;

	/* Family history of CRC */
	crcfh89=0;

	if sum (mclc89,fclc89, bclc89, sclc89)>0 then
		crcfh89=1;

	/* Family history of Diabetes */
	dbfh89=0;

	if sum (mdb89,fdb89, bdb89, sdb89)>0 then
		dbfh89=1;

	if db89=1 then
		db89=1;
	else db89=0;
run;

%nur91(
	keep=
		id      mamm91  mam91   ucol91   cpol91  sigm91  endo91
		brcn91  ocan91  mel91   hbp91    db91    chol91 oa91    brcn91 ocan91 mel91 can91
		mi91    wt91    ulcd91  endosx91 stndw91 stndh91 sitw91 sittv91 osith91
		agemn91 brfed91 mofed91 bthwt91  premt91 batch91
	);

	/* Cancer in 1991*/
	can91=0;

	if brcn91=1 or ocan91=1 or mel91=1 then
		can91=1;

	/* Mammogram */
	if mamm91 in (2,3) then
		mam91=1;
	else mam91=0;

	/* Lower endoscopy */
	if sigm91 in (2,3) then
		endo91=1;
	else endo91=0;

	/*indication for lower endoscopy*/
	endosx91=0;

	if sigm91 eq 2 then
		endosx91=1;

	if sigm91 eq 3 then
		endosx91=2;
run;

%nur93(keep=
		id    batch93 wt93  mamm93 mam93 sigm93 endo93 brcn93 ocan93 mel93
		hbp93 db93    chol93 oa93  mi93   ucol93 cpol93 msov93 mcanc93 fcanc93 cafh93 endosx93
	);

	/* Mammogram */
	if mamm93 in (2,3) then
		mam93=1;
	else mam93=0;

	if sigm93 in (2,3) then
		endo93=1;
	else endo93=0;

	/*endoscopic history*/
	endosx93=0;

	if sigm93 eq 2 then
		endosx93=1;

	if sigm93 eq 3 then
		endosx93=2;

	/* Family history of Cancer */
	cafh93=0;

	if msov93=2 or mcanc93=1 or fcanc93=1 then
		cafh93=1;
run;

%nur95(keep=
		id      batch95 wt95    mamm95 mam95 sigm95 endo95
		brcn95  ocan95  mel95   hbp95  db95  chol95 mi95 cabg95 ucol95 cpol95
		cimet95 h2blk95 h2ra95  endosx95
		app95   appa95  appda95 appc95
	);

	/* No Physical Exam */
	/* Mammogram */
	if mamm95 in (2,3) then
		mam95=1;
	else mam95=0;

	/* Lower endoscopy */
	if sigm95 in (2,3) then
		endo95=1;
	else endo95=0;
	endosx95=0;

	if sigm95 eq 2 then
		endosx95=1;

	if sigm95 eq 3 then
		endosx95=2;
	h2ra95=0;

	if cimet95=1 or h2blk95=1 then
		h2ra95=1;
run;

%nur97(keep=
		id      batch97 wt97    mamsc97 mamsy97 mam97   sigsc97  sigsy97 endo97 brcn97
		ocan97  mel97   hbp97   chol97  oa97    mi97    cabg97   ucol97  cpol97 cimet97 h2blk97 h2ra97
		mbrcn97 mbrcd97 sbrc197 sbr1d97 sbrc297 sbr2d97 mov97    sov97   pclc97 sclc197 sclc297
		pclcd97 scl1d97 scl2d97
		pmel97  smel97  cafh97  db97    crcfh97 endosx97 dbfh97  pdbd97 sbdb97  stndw97 stndh97
		sitw97  sittv97 sitot97
	);

	/* No Physical Exam */
	/* Mammogram */
	/* Screening and Symptoms */
	if mamsc97=1 or mamsy97=1 then
		mam97=1;
	else mam97=0;

	/* Lower endoscopy */
	if sigsc97=1 or sigsy97=1 then
		endo97=1;
	else endo97=0;
	endosx97=0;

	if sigsc97 eq 1 then
		endosx97=1;

	if sigsy97 eq 1 then
		endosx97=2;
	h2ra97=0;

	if cimet97=1 or h2blk97=1 then
		h2ra97=1;

	/* Family history of Cancer */
	cafh97=0;

	if sum (mbrcn97, sbrc197, sbrc297, mov97, sov97, pclc97, sclc197, sclc297, pmel97, smel97)>0 then
		cafh97=1;

	/* Family history of CRC */
	crcfh97=0;

	if sum (pclc97, sclc197, sclc297)>0 then
		crcfh97=1;

	/* Family history of Diabetes */
	dbfh97=0;

	if sum (pdbd97, sbdb97)>0 then
		dbfh97=1;
run;

%nur99(keep=
		id      q99    wt99  mamsc99 mamsy99 mam99 sigsc99 sigsy99 endo99
		brcn99  ocan99 mel99 hbp99   db99    chol99  oa99    mi99   cabg99 ucol99 cpol99 endosx99
		msmkp99 parsm99
	);

	/* No Physical Exam */
	/* Mammogram */
	/* Screening and Symptoms */
	if mamsc99=1 or mamsy99=1 then
		mam99=1;
	else mam99=0;

	/* Lower endoscopy */
	if sigsc99=1 or sigsy99=1 then
		endo99=1;
	else endo99=0;
	endosx99=0;

	if sigsc99 eq 1 then
		endosx99=1;

	if sigsy99 eq 1 then
		endosx99=2;
run;

%nur01(keep=
	id      q01     wt01     physc01 physy01 phexam01 mamsc01 mamsy01 mam01   sigm01 endo01
	ucol01  cpol01  brcn01   ocan01  mel01   hbp01    db01    chol01  oa01   mi01   cabg01 tag01 h2blk01
	h2ra01  prilo01 ppi01    mbrcn01 mbrcd01 sbrc101  sbr1d01 sbrc201 sbr2d01
	hxclc01 noov01  mov01    sov01   nobrc01 mbrcn01  sbrc101 sbrc201 noclc01 pclc01
	sclc101 sclc201 nout01   mut01   smut01  nopan01  ppan01  span01  pmel01  smel01
	cafh01  crcfh01 endosx01 vbld01  diarr01 fecal01  hxclc01 rout01  bariu01
	abdpn01 dbfh01  mdb01    fdb01   sdb01   stndw01  stndh01 sitw01  sittv01 sitho01
	);

	/* Physical Exam */
	if physc01=1 or physy01=1 then
		phexam01=1;
	else phexam01=0;

	/* Mammogram */
	if mamsc01=1 or mamsy01=1 then
		mam01=1;
	else mam01=0;

	/* Lower endoscopy */
	if sigm01=1 then
		endo01=1;
	else endo01=0;
	endosx01=0;

	if rout01=1 then
		endosx01=1;

	if vbld01=1 then
		endosx01=2;

	if diarr01=1 then
		endosx01=2;

	if fecal01=1 then
		endosx01=2;

	if hxclc01=1 then
		endosx01=2;

	if bariu01=1 then
		endosx01=2;

	if abdpn01=1 then
		endosx01=2;

	if sigm01=1 and endosx01 ne 2 then
		endosx01=1;
	h2ra01=0;

	if tag01=1 or h2blk01=1 then
		h2ra01=1;
	ppi01=0;

	if prilo01=1 then
		ppi01=1;

	/* Family history of Cancer */
	cafh01=0;

	if sum (mov01, sov01, mbrcn01, sbrc101, sbrc201, pclc01, sclc101, sclc201, mut01, smut01, ppan01, span01, pmel01, smel01)>0 then
		cafh01=1;
	crcfh01=0;

	if sum (pclc01, sclc101, sclc201)>0 then
		crcfh01=1;

	/* Family history of Diabetes */
	dbfh01=0;

	if sum (mdb01, fdb01, sdb01)>0 then
		dbfh01=1;
run;

%nur03(keep=
		id      q03   wt03     physc03 physy03 phexam03 sigm03  colsc03 endo03  brcn03
		ocan03  mel03 hbp03    db03    chol03  oa03     mi03    cabg03  ucol03  cpol03 h2blk03 h2ra03
		prilo03 ppi03 endosx03 vbld03  fecal03 abdpn03  diarr03 hxclc03 bariu03 virt03
		cpolp03 rout03
/*dairy foods*/
skim03d m1or203d whole03d cream03d sherb03d icecr03d flyog03d plyog03d cotch03d crmch03d  otch03d  but03d 
/* derived variables */
skim030  m1or203  whole03  cream03  sherb03  icecr03  flyog03  plyog03  cotch03  crmch03 otch03 but03
	);

array food {*} skim03d m1or203d whole03d cream03d sherb03d icecr03d flyog03d plyog03d cotch03d crmch03d  otch03d  but03d;
array foods{*} skim030  m1or203  whole03  cream03  sherb03  icecr03  flyog03  plyog03  cotch03  crmch03 otch03 but03;

do i=1 to dim(food);
if food{i}<=0 or food{i}>=9 then foods{i}=0; 
else if food{i}=1 then foods{i}=0.065; 
else if food{i}=2 then foods{i}=0.143;
else if food{i}=3 then foods{i}=0.429;
else if food{i}=4 then foods{i}=0.786;
else if food{i}=5 then foods{i}=1.0;
else if food{i}=6 then foods{i}=2.5;
else if food{i}=7 then foods{i}=4.5;
else if food{i}=8 then foods{i}=6.0; 
end;

	/* Physical Exam */
	if physc03=1 or physy03=1 then
		phexam03=1;
	else phexam03=0;

	/* Lower endoscopy */
	if sigm03=2 or colsc03=2 then
		endo03=1;
	else endo03=0;

	/*Coding for this year is different, $label 1.no; 2.yes; 3.pt*/
	endosx03=0;

	if rout03=1 then
		endosx03=1;

	if vbld03=1 then
		endosx03=2;

	if diarr03=1 then
		endosx03=2;

	if fecal03=1 then
		endosx03=2;

	if hxclc03=1 then
		endosx03=2;

	if bariu03=1 then
		endosx03=2;

	if abdpn03=1 then
		endosx03=2;

	if virt03=1 then
		endosx03=2;

	if cpolp03=1 then
		endosx03=2;

	if sigm03=2 and endosx03 ne 2 then
		endosx03=1;

	if colsc03=2 and endosx03 ne 2 then
		endosx03=1;

	/* Scope without a reason --> Screening */
	h2ra03=0;

	if h2blk03=1 then
		h2ra03=1;
	ppi03=0;

	if prilo03=1 then
		ppi03=1;
run;

%nur05(keep=
	id          wt05        physc05 physy05 phexam05 mamsc05  mamsy05  mam05
	colsc05     sigsc05     virtc05 endo05  brcn05   ocan05   mel05
	hbp05       db05        chol05  oa05    mi05     cabg05   ucol05   cpol05  h2blk05 h2ra05
	prilo05     ppi05       mbrcn05 mbrcd05 sbrc105  sbr1d05  sbrc205  sbr2d05
	hxclc05     mov05       sov05   mbrcn05 sbrc105  sbrc205  pclc05   sclc105 sclc205
	pmel05      smel05      mdcan05 fdcan05 cafh05   crcfh05
	db05        endosx05    vbld05  diarr05 bariu05  cpolp05  fecal05  hxclc05 virt05
	rout05      abdpn05     dbfh05      mdb05   fdb05   sdb05    stndw05  stndh05  sitw05  sittv05 sith05
	);


	/* Physical Exam */
	phexam05=0;

	if physc05=1 then phexam05=2;  /*screening*/

	if physy05=1 then phexam05=1;  /*symptom*/

	/* Mammogram */
	if mamsc05=1 or mamsy05=1 then
		mam05=1;
	else mam05=0;

	/* Lower endoscopy */
	if colsc05=2 or sigsc05=2 or virtc05=2 then
		endo05=1;
	else endo05=0;
	endosx05=0;

	if rout05=1 then
		endosx05=1;

	if vbld05=1 then
		endosx05=2;

	if diarr05=1 then
		endosx05=2;

	if fecal05=1 then
		endosx05=2;

	if hxclc05=1 then
		endosx05=2;

	if bariu05=1 then
		endosx05=2;

	if abdpn05=1 then
		endosx05=2;

	if virt05=1 then
		endosx05=2;

	if cpolp05=1 then
		endosx05=2;

	if sigsc05=2 and endosx05 ne 2 then
		endosx05=1;

	if colsc05=2 and endosx05 ne 2 then
		endosx05=1;

	if virtc05=2 and endosx05 ne 2 then
		endosx05=1;
	h2ra05=0;

	if h2blk05=1 then
		h2ra05=1;
	ppi05=0;

	if prilo05=1 then
		ppi05=1;

	/* Family history of Cancer */
	cafh05=0;

	if sum(mov05, sov05, mbrcn05, sbrc105, sbrc205, pclc05, sclc105, sclc205, mdcan05, fdcan05, pmel05,smel05)>0 then
		cafh05=1;

	/* Family history of CRC */
	crcfh05=0;

	if sum(pclc05, sclc105, sclc205)>0 then
		crcfh05=1;

	/* Family history of Diabetes */
	dbfh05=0;

	if sum (mdb05, fdb05, sdb05)>0 then
		dbfh05=1;
run;

%nur07(keep=
		id      q07     wt07    physc07 physy07 phexam07 mamsc07 mamsy07 mam07
		colsc07 sigsc07 virtc07 endo07  brcn07  ocan07   mel07   hbp07   db07    chol07
		oa07    mi07    cabg07  ucol07  cpol07  h2blk07  h2ra07  prilo07 ppi07   db07   endosx07
		vbld07  diarr07 bariu07 cpolp07 fecal07 hxclc07  virt07  rout07  abdpn07
/*dairy foods*/
skim07d m1or207d whole07d cream07d sherb07d icecr07d flyog07d plyog07d cotch07d crmch07d  otch07d but07d
/* derived variables */
skim070  m1or207  whole07  cream07  sherb07  icecr07  flyog07  plyog07  cotch07  crmch07 otch07 but07
	);
	
array food {*} skim07d m1or207d whole07d cream07d sherb07d icecr07d flyog07d plyog07d cotch07d crmch07d  otch07d but07d;
array foods{*} skim070  m1or207  whole07  cream07  sherb07  icecr07  flyog07  plyog07  cotch07  crmch07 otch07 but07;

do i=1 to dim(food);
if food{i}<=0 or food{i}>=9 then foods{i}=0; 
else if food{i}=1 then foods{i}=0.065; 
else if food{i}=2 then foods{i}=0.143;
else if food{i}=3 then foods{i}=0.429;
else if food{i}=4 then foods{i}=0.786;
else if food{i}=5 then foods{i}=1.0;
else if food{i}=6 then foods{i}=2.5;
else if food{i}=7 then foods{i}=4.5;
else if food{i}=8 then foods{i}=6.0; 
end;

	/* Physical Exam */
	phexam07=0;

	if physc07=1 then phexam07=2;  /*screening*/

	if physy07=1 then phexam07=1;  /*symptom*/

	/* Mammogram */
	if mamsc07=1 or mamsy07=1 then
		mam07=1;
	else mam07=0;

	/* Lower endoscopy */
	if colsc07=2 or sigsc07=2 or virtc07=2 then
		endo07=1;
	else endo07=0;
	endosx07=0;

	if rout07=1 then
		endosx07=1;

	if vbld07=1 then
		endosx07=2;

	if diarr07=1 then
		endosx07=2;

	if fecal07=1 then
		endosx07=2;

	if hxclc07=1 then
		endosx07=2;

	if bariu07=1 then
		endosx07=2;

	if abdpn07=1 then
		endosx07=2;

	if virt07=1 then
		endosx07=2;

	if cpolp07=1 then
		endosx07=2;

	if sigsc07=2 and endosx07 ne 2 then
		endosx07=1;

	if colsc07=2 and endosx07 ne 2 then
		endosx07=1;

	if virtc07=2 and endosx07 ne 2 then
		endosx07=1;
	h2ra07=0;

	if h2blk07=1 then
		h2ra07=1;
	ppi07=0;

	if prilo07=1 then
		ppi07=1;
run;

%nur09(keep=
		id      q09     wt09     physc09   physy09 phexam09 mamsc09 mamsy09 mam09
		colsc09 sigsc09 virtc09  endo09    brcn09  ocan09   mel09   hbp09   db09
		chol09  oa09    mi09     cabg09    h2blk09 h2ra09   ucol09  cpol09  prilo09 ppi09
		fdcan09 mdcan09 cafh09   endosx09  vbld09  diarr09  bariu09
		cpolp09 fecal09 hxclc09  rout09    abdpn09 mbrcn09  mbrcd09 sbrcn09
		sbrcd09 dbfh09    pdb09   sdb09    stndw09 stndh09
		sitw09  sittv09 sith09   pclc09    sclc109 sclc209  crcfh09 mov09   sov09   pmel09  smel09
	);

	/* Physical Exam */
	phexam09=0;

	if physc09=1 then phexam09=2;  /*screening*/

	if physy09=1 then phexam09=1;  /*symptom*/

	/* Mammogram */
	if mamsc09=1 or mamsy09=1 then
		mam09=1;
	else mam09=0;

	/* Lower endoscopy */
	if colsc09=2 or sigsc09=2 or virtc09=2 then
		endo09=1;
	else endo09=0;
	endosx09=0;

	if rout09=1 then
		endosx09=1;

	if vbld09=1 then
		endosx09=2;

	if diarr09=1 then
		endosx09=2;

	if fecal09=1 then
		endosx09=2;

	if hxclc09=1 then
		endosx09=2;

	if bariu09=1 then
		endosx09=2;

	if abdpn09=1 then
		endosx09=2;

	if cpolp09=1 then
		endosx09=2;

	if sigsc09=2 and endosx09 ne 2 then
		endosx09=1;

	if colsc09=2 and endosx09 ne 2 then
		endosx09=1;

	if virtc09=2 and endosx09 ne 2 then
		endosx09=1;
	h2ra09=0;

	if h2blk09=1 then
		h2ra09=1;
	ppi09=0;

	if prilo09=1 then
		ppi09=1;
		
	/*Family history of Cancer */
	cafh09=0;

	if sum(mdcan09, fdcan09, hxclc09, mov09, sov09, mbrcn09, sbrcn09, pclc09, sclc109, sclc209, pmel09, smel09)>0 then
		cafh09=1;

	/* Family history of Diabetes */
	dbfh09=0;

	if sum (pdb09, sdb09)>0 then
		dbfh09=1;

	/* Family history of CRC */
	crcfh09=0;

	if sum(pclc09, sclc109, sclc209)>0 then
		crcfh09=1;
run;


%nur11(keep=
		id       q11     wt11    physc11 physy11 phexam11 mamsc11 mamsy11 mam11
		colsc11  sigsc11 virtc11 endo11  brcn11  ocan11   mel11   hbp11   db11
		chol11   oa11    mi11    cabg11  h2blk11 h2ra11   ucol11  cpol11  prilo11 ppi11
		endosx11 vbld11  diarr11 bariu11 cpolp11 fecal11  hxclc11 rout11  abdpn11
/*dairy foods*/
skim11d	m1or211d whole11d cream11d sherb11d icecr11d but11d marg11d spbut11d plyog11d artyog11d flyog11d cotch11d	 crmch11d  otch11d 
skim11	m1or211 whole11 cream11 sherb11 icecr11 but11 marg11 spbut11 plyog11 artyog11 flyog11 cotch11	 crmch11  otch11
	);
	
array food {*} skim11d	m1or211d whole11d cream11d sherb11d icecr11d but11d marg11d spbut11d plyog11d artyog11d flyog11d cotch11d	 crmch11d  otch11d;
array foods{*} skim11	m1or211 whole11 cream11 sherb11 icecr11 but11 marg11 spbut11 plyog11 artyog11 flyog11 cotch11	 crmch11  otch11;

do i=1 to dim(food);
if food{i}<=0 or food{i}>=9 then foods{i}=0; 
else if food{i}=1 then foods{i}=0.065; 
else if food{i}=2 then foods{i}=0.143;
else if food{i}=3 then foods{i}=0.429;
else if food{i}=4 then foods{i}=0.786;
else if food{i}=5 then foods{i}=1.0;
else if food{i}=6 then foods{i}=2.5;
else if food{i}=7 then foods{i}=4.5;
else if food{i}=8 then foods{i}=6.0; 
end;

	/* Mammogram */
	if mamsc11=1 or mamsy11=1 then
		mam11=1;
	else mam11=0;

	/* Lower endoscopy */
	if colsc11=2 or sigsc11=2 or virtc11=2 then
		endo11=1;
	else endo11=0;
	endosx11=0;

	if rout11=1 then
		endosx11=1;

	if vbld11=1 then
		endosx11=2;

	if diarr11=1 then
		endosx11=2;

	if fecal11=1 then
		endosx11=2;

	if hxclc11=1 then
		endosx11=2;

	if bariu11=1 then
		endosx11=2;

	if abdpn11=1 then
		endosx11=2;

	if cpolp11=1 then
		endosx11=2;

	if sigsc11=2 and endosx11 ne 2 then
		endosx11=1;

	if colsc11=2 and endosx11 ne 2 then
		endosx11=1;

	if virtc11=2 and endosx11 ne 2 then
		endosx11=1;

	/* Physical Exam */
	phexam11=0;

	if physc11=1 then phexam11=2;  /*screening*/

	if physy11=1 then phexam11=1;  /*symptom*/
	h2ra11=0;

	if h2blk11=1 then
		h2ra11=1;
	ppi11=0;

	if prilo11=1 then
		ppi11=1;
run;

/* rough */
%nur13(keep=
		id       q13     wt13    physc13 physy13 phexam13 mamsc13 mamsy13 mam13
		colsc13  sigsc13 virtc13 endo13  brcn13  ocan13   mel13   hbp13   db13
		chol13   oa13    mi13    cabg13  h2blk13 h2ra13   ucol13  cpol13  prilo13 ppi13
		endosx13 vbld13  diarr13 bariu13 cpolp13 fecal13  hxclc13 rout13  abdpn13
		mdcan13  fdcan13 hxov13  hxbc13  hxmel13 hxcol13  cafh13  crcfh13 hxdb13  dbfh13
	);
	
	/* Family history of CRC */
	crcfh13=0;

	if hxcol13=2 then
		crcfh13=1;

	/* Mammogram */
	if mamsc13=1 or mamsy13=1 then
		mam13=1;
	else mam13=0;

	/* Lower endoscopy */
	if colsc13=2 or sigsc13=2 or virtc13=2 then
		endo13=1;
	else endo13=0;
	endosx13=0;

	if rout13=1 then
		endosx13=1;

	if vbld13=1 then
		endosx13=2;

	if diarr13=1 then
		endosx13=2;

	if fecal13=1 then
		endosx13=2;

	if hxclc13=1 then
		endosx13=2;

	if bariu13=1 then
		endosx13=2;

	if abdpn13=1 then
		endosx13=2;

	if cpolp13=1 then
		endosx13=2;

	if sigsc13=2 and endosx13 ne 2 then
		endosx13=1;

	if colsc13=2 and endosx13 ne 2 then
		endosx13=1;

	if virtc13=2 and endosx13 ne 2 then
		endosx13=1;

	/* Physical Exam */
	phexam13=0;

	if physc13=1 then phexam13=2;  /*screening*/

	if physy13=1 then phexam13=1;  /*symptom*/
	h2ra13=0;

	if h2blk13=1 then
		h2ra13=1;
	ppi13=0;

	if prilo13=1 then
		ppi13=1;
		
	/*Family history of Cancer*/
	cafh13=0;

	if sum(mdcan13, fdcan13, hxclc13)>1 | hxov13=2 | hxbc13=2 | hxmel13=2 | hxcol13=2  then
		cafh13=1;
		
	/* Family history of Diabetes */
	dbfh13=0;
	
	if hxdb13=2 then 
		dbfh13=1;
run;

/*** Physical Activity ***/
%act8917(keep=id act89m act91m act97m act01m act05m act09m act13m);
	array acta act89m act91m act97m act01m act05m act09m act13m;
	do over acta;
		if acta in (998, 999) then acta=.;
	end;
run;


/*** Multivitamin Use ***/
/* 0.nonuser
   1.current user
   9.unknown status
*/
%supp8913(keep=id mvitu89 mvitu91 mvitu93 mvitu95 mvitu97 mvitu99 mvitu01 mvitu03 mvitu05 mvitu07 mvitu09 mvitu11 mvitu13);
	array mvitua mvitu89 mvitu91 mvitu93 mvitu95 mvitu97 mvitu99 mvitu01 mvitu03 mvitu05 mvitu07 mvitu09 mvitu11 mvitu13;
	do over mvitua;
		if mvitua=9 then mvitua=.;
	end;
run;

/*** AHEI (Alternative Healthing Eating Index) - without alcohol ***/
%ahei2010_9115(keep=id ahei2010_noETOH91 ahei2010_noETOH95 ahei2010_noETOH99 ahei2010_noETOH03 ahei2010_noETOH07 ahei2010_noETOH11);
run;

/*dairy foods*/
%n91_dt(keep=id skim91d whole91d cream91d  sour91d sherb91d icecr91d   yog91d cotch91d crmch91d  otch91d marg91d   but91d  
skim91  whole91  cream91   sour91  sherb91  icecr91 yog91  cotch91  crmch91   otch91 marg91   but91);

array food {*} skim91d whole91d cream91d  sour91d sherb91d icecr91d   yog91d cotch91d crmch91d  otch91d marg91d   but91d;
array foods{*}   skim91  whole91  cream91   sour91  sherb91  icecr91 yog91  cotch91  crmch91   otch91 marg91   but91;

do i=1 to dim(food);

/*
	$label 0.never or <1/month; 1.1-3/mo; 2.1/week;
	3.2-4/wk; 4.5-6/wk; 5.1/day; 6.2-3/day;
	7.4-5/day; 8.6+/day; 9.pt
*/ 
if food{i}<=0 or food{i}>=9 then foods{i}=0; 
else if food{i}=1 then foods{i}=0.065; 
else if food{i}=2 then foods{i}=0.143;
else if food{i}=3 then foods{i}=0.429;
else if food{i}=4 then foods{i}=0.786;
else if food{i}=5 then foods{i}=1.0;
else if food{i}=6 then foods{i}=2.5;
else if food{i}=7 then foods{i}=4.5;
else if food{i}=8 then foods{i}=6.0; 
end;
run;

%n95_dt(keep=    id skim95d m1or295d whole95d cream95d sherb95d icecr95d flyog95d plyog95d cotch95d crmch95d 
                 otch95d     but95d  skim950  m1or295  whole95  cream95  sherb95  icecr95  flyog95  plyog95  cotch95  crmch95   otch95  but95);

array food {*} skim95d m1or295d whole95d cream95d sherb95d icecr95d flyog95d plyog95d cotch95d crmch95d 
                 otch95d     but95d;
array foods{*} skim950  m1or295  whole95  cream95  sherb95  icecr95  flyog95  plyog95  cotch95  crmch95   otch95  but95;

do i=1 to dim(food);
 
if food{i}<=0 or food{i}>=9 then foods{i}=0; 
else if food{i}=1 then foods{i}=0.065; 
else if food{i}=2 then foods{i}=0.143;
else if food{i}=3 then foods{i}=0.429;
else if food{i}=4 then foods{i}=0.786;
else if food{i}=5 then foods{i}=1.0;
else if food{i}=6 then foods{i}=2.5;
else if food{i}=7 then foods{i}=4.5;
else if food{i}=8 then foods{i}=6.0; 
end;
run;

%n99_dt(keep= id skim99d m299d whole99d cream99d sherb99d icecr99d flyog99d plyog99d cotch99d crmch99d  otch99d  but99d
/* derived variables */
skim990  m299  whole99  cream99  sherb99  icecr99  flyog99  plyog99  cotch99  crmch99   otch99 but99);

array food {*} skim99d m299d whole99d cream99d sherb99d icecr99d flyog99d plyog99d cotch99d crmch99d  otch99d  but99d;
array foods{*} skim990  m299  whole99  cream99  sherb99  icecr99  flyog99  plyog99  cotch99  crmch99   otch99 but99;

do i=1 to dim(food);
 
if food{i}<=0 or food{i}>=9 then foods{i}=0; 
else if food{i}=1 then foods{i}=0.065; 
else if food{i}=2 then foods{i}=0.143;
else if food{i}=3 then foods{i}=0.429;
else if food{i}=4 then foods{i}=0.786;
else if food{i}=5 then foods{i}=1.0;
else if food{i}=6 then foods{i}=2.5;
else if food{i}=7 then foods{i}=4.5;
else if food{i}=8 then foods{i}=6.0; 
end;
run;



/*** Check if there's any duplicate variable rather than ID ***/
%compmerge(list=calciumdata deadff nhs2asp nhs2meat 
		act8917 der8917 supp8913 ahei2010_9115 cancer
		nur89 nur91 nur93 nur95 nur97 nur99 nur01 nur03 nur05 nur07 nur09 nur11 nur13
		n91_dt n95_dt n99_dt
		Dscore);

/*** Merge, construct wide file ***/
data nhs2;
	merge
		calciumdata deadff nhs2asp nhs2meat 
		act8917 der8917 supp8913 ahei2010_9115 cancer
		nur89 nur91 nur93 nur95 nur97 nur99 nur01 nur03 nur05 nur07 nur09 nur11 nur13
		n91_dt n95_dt n99_dt 
		Dscore
		end=_end_;
	by id;

	exrec=1;

	if first.id then
		exrec=0;

	/* Those definitions have overlaps in year, so put it here */
		
	if endo91=1 then
		endo91=1;
	else endo91=0;


	array endosxa       {*} endosx91       endosx93       endosx95       endosx97       endosx99       endosx01       endosx03       endosx05       endosx07       endosx09       endosx11       endosx13       ;
	array endoalla      {*} endoall91      endoall93      endoall95      endoall97      endoall99      endoall01      endoall03      endoall05      endoall07      endoall09      endoall11      endoall13      ;
	array endocarrya    {*} endocarry91    endocarry93    endocarry95    endocarry97    endocarry99    endocarry01    endocarry03    endocarry05    endocarry07    endocarry09    endocarry11    endocarry13    ;
	array screencarrya  {*} screencarry91  screencarry93  screencarry95  screencarry97  screencarry99  screencarry01  screencarry03  screencarry05  screencarry07  screencarry09  screencarry11  screencarry13  ;
	array symptomcarrya {*} symptomcarry91 symptomcarry93 symptomcarry95 symptomcarry97 symptomcarry99 symptomcarry01 symptomcarry03 symptomcarry05 symptomcarry07 symptomcarry09 symptomcarry11 symptomcarry13 ;

	/* Screening (1) or Symptoms (2) */
	/* Carry back endosx91 one cycle */
	/* 1=screening, 2=symptom to yes and no */
	do i=1 to dim(endosxa);
		if endosxa{i} in (1,2) then endoalla{i}=1;
		else endoalla{i}=0;
	end;
	

	do j=dim(endocarrya) to 1 by -1;
		if j>3 then do;
			/* Assume 10-year protection of endoscopy */
			if endoalla{j}=1 or endoalla{j-1}=1 or endoalla{j-2}=1 or endoalla{j-3}=1 then endocarrya{j}=1;
			else endocarrya{j}=0;
			
			/* Assume 10 year-protection of endoscopy, carry forward only screening endoscopy */
			if endosxa{j}=1 or endosxa{j-1}=1 or endosxa{j-2}=1 or endosxa{j-3}=1 then screencarrya{j}=1;
			else screencarrya{j}=0;
			
			/* Assume 10-year protection of endoscopy, carry forward only symptom endoscopy */
			if endosxa{j}=2 or endosxa{j-1}=2 or endosxa{j-2}=2 or endosxa{j-3}=2 then symptomcarrya{j}=1;
			else symptomcarrya{j}=0;
		end;
		
		else if j=3 then do;
			if endoalla{j}=1 or endoalla{j-1}=1 or endoalla{j-2}=1 then endocarrya{j}=1;
			else endocarrya{j}=0;
			
			if endosxa{j}=1 or endosxa{j-1}=1 or endosxa{j-2}=1 then screencarrya{j}=1;
			else screencarrya{j}=0;
			
			if endosxa{j}=2 or endosxa{j-1}=2 or endosxa{j-2}=2 then symptomcarrya{j}=1;
			else symptomcarrya{j}=0;
		end;
		
		else if j=2 then do;
			if endoalla{j}=1 or endoalla{j-1}=1 then endocarrya{j}=1;
			else endocarrya{j}=0;
			
			if endosxa{j}=1 or endosxa{j-1}=1 then screencarrya{j}=1;
			else screencarrya{j}=0;
			
			if endosxa{j}=2 or endosxa{j-1}=2 then symptomcarrya{j}=1;
			else symptomcarrya{j}=0;
		end;

		else if j=1 then do;
			if endoalla{j}=1 then endocarrya{j}=1;
			else endocarrya{j}=0;
			
			if endosxa{j}=1 then screencarrya{j}=1;
			else screencarrya{j}=0;
			
			if endosxa{j}=2 then symptomcarrya{j}=1;
			else symptomcarrya{j}=0;
		end;
	end;

run;

/*** Delete the intermediates ***/
proc datasets;
	delete
		calciumdata deadff nhs2asp nhs2meat
		act8917 der8917 supp8913 ahei2010_9115 cancer
		nur89 nur91 nur93 nur95 nur97 nur99 nur01 nur03 nur05 nur07 nur09 nur11 nur13
		n91_dt n95_dt n99_dt
		Dscore
	;
run;

/*** Expanding wide file to long file ***/
data nhs2; /* Use index instead of sort b/c this dataset is large (~2gb) */
	set nhs2 end=_end_;

	/* Initialize the environment for %exclude, put this outside the master loop */
	%beginex();
	
	/* Start to create period-based covariate using %output (Load all data to PDV then output to the dataset), starting from 80 */
	
	/* Variables updated during follow up */
	array irt{*} irt89 irt91 irt93 irt95 irt97 irt99 irt01 irt03 irt05 irt07 irt09 irt11 irt13 cutoff;
	array tv {*} t89   t91   t93   t95   t97   t99   t01   t03   t05   t07   t09   t11   t13;
	array period {*} period1-period13;

	/* Correct questionnaire return date */
	do i=1 to dim(irt);
		if irt{i}< 1050+(24*i) or irt{i}>=1074+(24*i) then
			irt{i}=1050+(24*i);
	end;

	cutoff=1386;

	dtReach50=birthday + 600;

	/* Get Event Macro **/
	/* create person-year and outcome of interest within each QQ cycle */
	/* writing my own macro named "getevent" w macro variable named "event"-> whatever I put for "event" will replace "&event." in the macro */
	%macro getevent(event); 	
	/*initialize Y (i.e.dt_&event.), T (t_&event.) for COX -> equivalent to defining Y, T for non-cases who are alive */
	dt_&event.=0;

	/*Y: e.g. event=ca->macro will generate dt_ca=0;*/
	t_&event.=irt{i+1}-irt{i};

	/*T: e.g. event=ca->macro will generate t_ca=irt{i+1}-irt{i};*/
	/*for cases in the current period (i) --> define Y, T*/
	if &event.=1 and irt{i}<dtdxcrc<=irt{i+1} then
		do;
			/*if cases in this cycle*/
			dt_&event.=1;

			/*Y=1*/
			t_&event.=dtdxcrc-irt{i};

			/*T=between date dignosis and prev. return month*/
		end;

	/*for death in the current period (i)->define T*/
	/*of note, death is not outcome and thus, keep Y=0 as it was initialized (i.e. need to define only T for death)*/
	if irt{i} le dtdth lt irt{i+1} then
		t_&event.=min(t_&event., dtdth-irt{i});

	/*if deaths in this cycle*/

	/*T=minimum of t_&event. vs time to death:
	i) if death w/o event: t_&event.= irt{i+1}-irt{i}
	ii) if death a/f event: t_&event.=dtdxca-irt{i}*/
	%mend;

/*dairy foods*/
cream91_c=sum(cream91d,  sour91d);
skim95_c=sum(skim950,  m1or295);
yog95=sum(flyog95,  plyog95);
skim99_c=sum(skim990,  m299);
yog99=sum(flyog99,  plyog99);
skim03_c=sum(skim030,  m1or203);
yog03=sum(flyog03,  plyog03);
skim07_c=sum(skim070,  m1or207 );
yog07=sum(flyog07,  plyog07);
skim11_c=sum(skim11,m1or211);
but11_c=sum(but11,spbut11);
yog11=sum(plyog11, artyog11, flyog11);

	
	/*** Arrays and Cumulative Pascal Triangle ***/
	
	/*** Arrays ***/
	
	/* Main Exposure: Calcium */
	array calca          {*} calc91a         calc91a         calc91a         calc95a         calc95a         calc99a         calc99a         calc03a         calc03a         calc07a         calc07a         calc11a         calc11a         ;
	array calccuma       {*} calc91cum       calc91cum       calc91cum       calc95cum       calc95cum       calc99cum       calc99cum       calc03cum       calc03cum       calc07cum       calc07cum       calc11cum       calc11cum       ;
	array diet_calca     {*} calc_91a        calc_91a        calc_91a        calc_95a        calc_95a        calc_99a        calc_99a        calc_03a        calc_03a        calc_07a        calc_07a        calc_11a        calc_11a        ;
	array diet_calccuma  {*} calc_91cum      calc_91cum      calc_91cum      calc_95cum      calc_95cum      calc_99cum      calc_99cum      calc_03cum      calc_03cum      calc_07cum      calc_07cum      calc_11cum      calc_11cum      ;
	array dcalca    {*} dcalc91a   dcalc91a   dcalc91a   dcalc95a   dcalc95a   dcalc99a   dcalc99a   dcalc03a   dcalc03a   dcalc07a   dcalc07a   dcalc11a   dcalc11a   ;
	array dcalccuma {*} dcalc91cum dcalc91cum dcalc91cum dcalc95cum dcalc95cum dcalc99cum dcalc99cum dcalc03cum dcalc03cum dcalc07cum dcalc07cum dcalc11cum dcalc11cum ;
    array ndda    {*}  ndd91a         ndd91a         ndd91a         ndd95a         ndd95a         ndd99a         ndd99a         ndd03a         ndd03a         ndd07a         ndd07a         ndd11a         ndd11a;
    array nddcuma {*}  ndd91cum       ndd91cum       ndd91cum       ndd95cum       ndd95cum       ndd99cum       ndd99cum       ndd03cum       ndd03cum       ndd07cum       ndd07cum       ndd11cum       ndd11cum;
	array supp_calca     {*} supp_calc91a    supp_calc91a    supp_calc91a    supp_calc95a    supp_calc95a    supp_calc99a    supp_calc99a    supp_calc03a    supp_calc03a    supp_calc07a    supp_calc07a    supp_calc11a    supp_calc11a    ;
	array supp_calccuma  {*} supp_calc91cum  supp_calc91cum  supp_calc91cum  supp_calc95cum  supp_calc95cum  supp_calc99cum  supp_calc99cum  supp_calc03cum  supp_calc03cum  supp_calc07cum  supp_calc07cum  supp_calc11cum  supp_calc11cum  ;

	do i=1 to dim(diet_calca);
		/* Calculate non-dairy dietary calcium intake (dietary - dairy) */
		ndda{i}=diet_calca{i}-dcalca{i};
		/* Mark 0 */
		if ndda{i}<0 then ndda{i}=0;
	end;
	
/*dairy foods*/
array skim_d {*} skim91 skim91 skim91 skim95_c skim95_c skim99_c skim99_c skim03_c skim03_c skim07_c skim07_c skim11_c skim11_c;
array skimcuma {*} skim91cum skim91cum skim91cum skim95cum skim95cum skim99cum skim99cum skim03cum skim03cum skim07cum skim07cum skim11cum skim11cum;
array yog_d {*} yog91 yog91 yog91 yog95 yog95 yog99 yog99 yog03 yog03 yog07 yog07 yog11 yog11;
array yogcuma {*} yog91cum yog91cum yog91cum yog95cum yog95cum yog99cum yog99cum yog03cum yog03cum yog07cum yog07cum yog11cum yog11cum;
array whole_d {*} whole91 whole91 whole91 whole95 whole95 whole99 whole99 whole03 whole03 whole07 whole07 whole11 whole11;
array wholecuma {*} whole91cum whole91cum whole91cum whole95cum whole95cum whole99cum whole99cum whole03cum whole03cum whole07cum whole07cum whole11cum whole11cum;
array ice_d {*} icecr91 icecr91 icecr91 icecr95 icecr95 icecr99 icecr99 icecr03 icecr03 icecr07 icecr07 icecr11 icecr11;
array icecuma {*} icecr91cum icecr91cum icecr91cum icecr95cum icecr95cum icecr99cum icecr99cum icecr03cum icecr03cum icecr07cum icecr07cum icecr11cum icecr11cum;
array cot_d {*} cotch91 cotch91 cotch91 cotch95 cotch95 cotch99 cotch99 cotch03 cotch03 cotch07 cotch07 cotch11 cotch11;
array cotchcuma {*} cotch91cum cotch91cum cotch91cum cotch95cum cotch95cum cotch99cum cotch99cum cotch03cum cotch03cum cotch07cum cotch07cum cotch11cum cotch11cum;
array sher_d {*} sherb91 sherb91 sherb91 sherb95 sherb95 sherb99 sherb99 sherb03 sherb03 sherb07 sherb07 sherb11 sherb11;
array shercuma {*} sherb91cum sherb91cum sherb91cum sherb95cum sherb95cum sherb99cum sherb99cum sherb03cum sherb03cum sherb07cum sherb07cum sherb11cum sherb11cum;
array crea_d {*} cream91_c cream91_c cream91_c cream95 cream95 cream99 cream99 cream03 cream03 cream07 cream07 cream11 cream11;
array creamcuma {*} cream91cum cream91cum cream91cum cream95cum cream95cum cream99cum cream99cum cream03cum cream03cum cream07cum cream07cum cream11cum cream11cum;
array crm_d {*} crmch91 crmch91 crmch91 crmch95 crmch95 crmch99 crmch99 crmch03 crmch03 crmch07 crmch07 crmch11 crmch11;
array crmchcuma {*} crmch91cum crmch91cum crmch91cum crmch95cum crmch95cum crmch99cum crmch99cum crmch03cum crmch03cum crmch07cum crmch07cum crmch11cum crmch11cum;
array otch_d {*} otch91 otch91 otch91 otch95 otch95 otch99 otch99 otch03 otch03 otch07 otch07 otch11 otch11;
array otchcuma {*} otch91cum otch91cum otch91cum otch95cum otch95cum otch99cum otch99cum otch03cum otch03cum otch07cum otch07cum otch11cum otch11cum;
array but_d {*} but91 but91 but91 but95 but95 but99 but99 but03 but03 but07 but07 but11_c but11_c;
array butcuma {*} but91cum but91cum but91cum but95cum but95cum but99cum but99cum but03cum but03cum but07cum but07cum but11cum but11cum;

	/* Covariates */
	array bmia           {*} bmi89           bmi91           bmi93           bmi95           bmi97           bmi99           bmi01           bmi03           bmi05           bmi07           bmi09           bmi11           bmi13           ;
	array bmicuma        {*} bmi89cum        bmi91cum        bmi93cum        bmi95cum        bmi97cum        bmi99cum        bmi01cum        bmi03cum        bmi05cum        bmi07cum        bmi09cum        bmi11cum        bmi13cum        ;
	array dba            {*} db89            db91            db93            db95            db97            db99            db01            db03            db05            db07            db09            db11            db13            ;
	array cafha          {*} cafh89          cafh89          cafh93          cafh93          cafh97          cafh97          cafh01          cafh01          cafh05          cafh05          cafh09          cafh09          cafh13          ;
	array crcfha         {*} crcfh89         crcfh89         crcfh89         crcfh89         crcfh97         crcfh97         crcfh01         crcfh01         crcfh05         crcfh05         crcfh09         crcfh09         crcfh13         ;
	array dbfha          {*} dbfh89          dbfh89          dbfh89          dbfh89          dbfh97          dbfh97          dbfh01          dbfh01          dbfh05          dbfh05          dbfh09          dbfh09          dbfh13          ;
	array phexama        {*} phexam89        phexam89        phexam89        phexam89        phexam89        phexam89        phexam01        phexam03        phexam05        phexam07        phexam09        phexam11        phexam13        ;
	array mama           {*} mam89           mam91           mam93           mam95           mam97           mam99           mam01           mam01           mam05           mam07           mam09           mam11           mam13           ;
	array endoa          {*} endo91          endo91          endo93          endo95          endo97          endo99          endo01          endo03          endo05          endo07          endo09          endo11          endo13          ;
	array endosxa        {*} endosx91        endosx91        endosx93        endosx95        endosx97        endosx99        endosx01        endosx03        endosx05        endosx07        endosx09        endosx11        endosx13        ;
	array endoalla       {*} endoall91       endoall91       endoall93       endoall95       endoall97       endoall99       endoall01       endoall03       endoall05       endoall07       endoall09       endoall11       endoall13       ;
	array endocarrya     {*} endocarry91     endocarry91     endocarry93     endocarry95     endocarry97     endocarry99     endocarry01     endocarry03     endocarry05     endocarry07     endocarry09     endocarry11     endocarry13     ;
	array sxcarrya       {*} symptomcarry91  symptomcarry91  symptomcarry93  symptomcarry95  symptomcarry97  symptomcarry99  symptomcarry01  symptomcarry03  symptomcarry05  symptomcarry07  symptomcarry09  symptomcarry11  symptomcarry13  ;
	array sccarrya       {*} screencarry91   screencarry91   screencarry93   screencarry95   screencarry97   screencarry99   screencarry01   screencarry03   screencarry05   screencarry07   screencarry09   screencarry11   screencarry13   ;

/*meds8915 doesnt have aspirin in 1991 and nsaid in 1991&1993*/
	array regaspa        {*} regaspre93      regaspre93      regaspre93      regaspre95      regaspre97      regaspre99      regaspre01      regaspre03      regaspre05      regaspre07      regaspre09      regaspre11      regaspre13      ;
	array nsaida         {*} regibui95       regibui95       regibui95       regibui95       regibui97       regibui99       regibui01       regibui03       regibui05       regibui07       regibui09       regibui11       regibui13       ;

	array mvta           {*} mvitu89         mvitu91         mvitu93         mvitu95         mvitu97         mvitu99         mvitu01         mvitu03         mvitu05         mvitu07         mvitu09         mvitu11         mvitu13         ;
	array alcoa          {*} alco91n         alco91n         alco91n         alco95n         alco95n         alco99n         alco99n         alco03n         alco03n         alco07n         alco07n         alco11n         alco11n         ;
	array alcocuma       {*} alco91ncum      alco91ncum      alco91ncum      alco95ncum      alco95ncum      alco99ncum      alco99ncum      alco03ncum      alco03ncum      alco07ncum      alco07ncum      alco11ncum      alco11ncum      ;
	array pckyra         {*} pkyr89          pkyr91          pkyr93          pkyr95          pkyr97          pkyr99          pkyr01          pkyr03          pkyr05          pkyr07          pkyr09          pkyr11          pkyr13          ;
	array fibera         {*} aofib91a        aofib91a        aofib91a        aofib95a        aofib95a        aofib99a        aofib99a        aofib03a        aofib03a        aofib07a        aofib07a        aofib11a        aofib11a        ;
	array fibercuma      {*} aofib91cum      aofib91cum      aofib91cum      aofib95cum      aofib95cum      aofib99cum      aofib99cum      aofib03cum      aofib03cum      aofib07cum      aofib07cum      aofib11cum      aofib11cum      ;

	array vitda          {*} vitd91a         vitd91a         vitd91a         vitd95a         vitd95a         vitd99a         vitd99a         vitd03a         vitd03a         vitd07a         vitd07a         vitd11a         vitd11a         ;
	array vitdcuma       {*} vitd91cum       vitd91cum       vitd91cum       vitd95cum       vitd95cum       vitd99cum       vitd99cum       vitd03cum       vitd03cum       vitd07cum       vitd07cum       vitd11cum       vitd11cum       ;

	array caloriea       {*} calor91n        calor91n        calor91n        calor95n        calor95n        calor99n        calor99n        calor03n        calor03n        calor07n        calor07n        calor11n        calor11n        ;
	array caloriecuma    {*} calor91cum      calor91cum      calor91cum      calor95cum      calor95cum      calor99cum      calor99cum      calor03cum      calor03cum      calor07cum      calor07cum      calor11cum      calor11cum      ;
	array folatea        {*} fol91a          fol91a          fol91a          fol95a          fol95a          fol9899a        fol9899a        fol9803a        fol9803a        fol9807a        fol9807a        fol9811a        fol9811a        ;
	array folatecuma     {*} fol91cum        fol91cum        fol91cum        fol95cum        fol95cum        fol99cum        fol99cum        fol03cum        fol03cum        fol07cum        fol07cum        fol11cum        fol11cum        ;
	array naheia         {*} nahei91         nahei91         nahei91         nahei95         nahei95         nahei99         nahei99         nahei03         nahei03         nahei07         nahei07         nahei11         nahei11         ;
	array naheicuma      {*} nahei91cum      nahei91cum      nahei91cum      nahei95cum      nahei95cum      nahei99cum      nahei99cum      nahei03cum      nahei03cum      nahei07cum      nahei07cum      nahei11cum      nahei11cum      ;
	array rpmeatsa       {*} rpmeats91       rpmeats91       rpmeats91       rpmeats95       rpmeats95       rpmeats99       rpmeats99       rpmeats03       rpmeats03       rpmeats07       rpmeats07       rpmeats11       rpmeats11       ;
	array rpmeatscuma    {*} rpmeat91scum    rpmeat91scum    rpmeat91scum    rpmeat95scum    rpmeat95scum    rpmeat99scum    rpmeat99scum    rpmeat03scum    rpmeat03scum    rpmeat07scum    rpmeat07scum    rpmeat11scum    rpmeat11scum    ;
	array actma          {*} act89m          act91m          act91m          act91m          act97m          act97m          act01m          act01m          act05m          act05m          act09m          act09m          act13m          ;
	array actmcuma       {*} act89cum        act91cum        act91cum        act91cum        act97cum        act97cum        act01cum        act01cum        act05cum        act05cum        act09cum        act09cum        act13cum        ;
	array dmnp           {*} mnpst89         mnpst91         mnpst93         mnpst95         mnpst97         mnpst99         mnpst01         mnpst03         mnpst05         mnpst07         mnpst09         mnpst11         mnpst13         ;
	array hor            {*} nhor89          nhor91          nhor93          nhor95          nhor97          nhor99          nhor01          nhor03          nhor05          nhor07          nhor09          nhor11          nhor13          ;
	array ucola          {*} ucol89          ucol91          ucol93          ucol95          ucol97          ucol99          ucol01          ucol03          ucol05          ucol07          ucol09          ucol11          ucol13          ;
	array cpola          {*} cpol91          cpol91          cpol93          cpol95          cpol97          cpol99          cpol01          cpol03          cpol05          cpol07          cpol09          cpol11          cpol13          ;

	/*** Cumulative Pascal Triangle ***/
	
	/* Main Exposure does not need to be carried forward, so put outside the master loop */
	calc91cum=calc91a;
	calc95cum=mean(calc91a, calc95a);
	calc99cum=mean(calc91a, calc95a, calc99a);
	calc03cum=mean(calc91a, calc95a, calc99a, calc03a);
	calc07cum=mean(calc91a, calc95a, calc99a, calc03a, calc07a);
	calc11cum=mean(calc91a, calc95a, calc99a, calc03a, calc07a, calc11a);

	calc_91cum=calc_91a;
	calc_95cum=mean(calc_91a, calc_95a);
	calc_99cum=mean(calc_91a, calc_95a, calc_99a);
	calc_03cum=mean(calc_91a, calc_95a, calc_99a, calc_03a);
	calc_07cum=mean(calc_91a, calc_95a, calc_99a, calc_03a, calc_07a);
	calc_11cum=mean(calc_91a, calc_95a, calc_99a, calc_03a, calc_07a, calc_11a);

	dcalc91cum=dcalc91a;
	dcalc95cum=mean(dcalc91a, dcalc95a);
	dcalc99cum=mean(dcalc91a, dcalc95a, dcalc99a);
	dcalc03cum=mean(dcalc91a, dcalc95a, dcalc99a, dcalc03a);
	dcalc07cum=mean(dcalc91a, dcalc95a, dcalc99a, dcalc03a, dcalc07a);
	dcalc11cum=mean(dcalc91a, dcalc95a, dcalc99a, dcalc03a, dcalc07a, dcalc11a);
	
	ndd91cum=ndd91a;
	ndd95cum=mean(ndd91a, ndd95a);
	ndd99cum=mean(ndd91a, ndd95a, ndd99a);
	ndd03cum=mean(ndd91a, ndd95a, ndd99a, ndd03a);
	ndd07cum=mean(ndd91a, ndd95a, ndd99a, ndd03a, ndd07a);
	ndd11cum=mean(ndd91a, ndd95a, ndd99a, ndd03a, ndd07a, ndd11a);
	
	supp_calc91cum=supp_calc91a;
	supp_calc95cum=mean(supp_calc91a, supp_calc95a);
	supp_calc99cum=mean(supp_calc91a, supp_calc95a, supp_calc99a);
	supp_calc03cum=mean(supp_calc91a, supp_calc95a, supp_calc99a, supp_calc03a);
	supp_calc07cum=mean(supp_calc91a, supp_calc95a, supp_calc99a, supp_calc03a, supp_calc07a);
	supp_calc11cum=mean(supp_calc91a, supp_calc95a, supp_calc99a, supp_calc03a, supp_calc07a, supp_calc11a);

/*dairy foods*/
	skim91cum=skim91;
	skim95cum=mean(skim91, skim95_c);
	skim99cum=mean(skim91, skim95_c, skim99_c);
	skim03cum=mean(skim91, skim95_c, skim99_c, skim03_c);
	skim07cum=mean(skim91, skim95_c, skim99_c, skim03_c, skim07_c);
	skim11cum=mean(skim91, skim95_c, skim99_c, skim03_c, skim07_c, skim11_c);
	
	yog91cum=yog91;
	yog95cum=mean(yog91, yog95);
	yog99cum=mean(yog91, yog95, yog99);
	yog03cum=mean(yog91, yog95, yog99, yog03);
	yog07cum=mean(yog91, yog95, yog99, yog03, yog07);
	yog11cum=mean(yog91, yog95, yog99, yog03, yog07, yog11);
	
	whole91cum=whole91;
	whole95cum=mean(whole91, whole95);
	whole99cum=mean(whole91, whole95, whole99);
	whole03cum=mean(whole91, whole95, whole99, whole03);
	whole07cum=mean(whole91, whole95, whole99, whole03, whole07);
	whole11cum=mean(whole91, whole95, whole99, whole03, whole07, whole11);
	
	icecr91cum=icecr91;
	icecr95cum=mean(icecr91, icecr95);
	icecr99cum=mean(icecr91, icecr95, icecr99);
	icecr03cum=mean(icecr91, icecr95, icecr99, icecr03);
	icecr07cum=mean(icecr91, icecr95, icecr99, icecr03, icecr07);
	icecr11cum=mean(icecr91, icecr95, icecr99, icecr03, icecr07, icecr11);
	
	cotch91cum=cotch91;
	cotch95cum=mean(cotch91, cotch95);
	cotch99cum=mean(cotch91, cotch95, cotch99);
	cotch03cum=mean(cotch91, cotch95, cotch99, cotch03);
	cotch07cum=mean(cotch91, cotch95, cotch99, cotch03, cotch07);
	cotch11cum=mean(cotch91, cotch95, cotch99, cotch03, cotch07, cotch11);
	
	sherb91cum=sherb91;
	sherb95cum=mean(sherb91, sherb95);
	sherb99cum=mean(sherb91, sherb95, sherb99);
	sherb03cum=mean(sherb91, sherb95, sherb99, sherb03);
	sherb07cum=mean(sherb91, sherb95, sherb99, sherb03, sherb07);
	sherb11cum=mean(sherb91, sherb95, sherb99, sherb03, sherb07, sherb11);
	
	cream91cum=cream91_c;
	cream95cum=mean(cream91_c, cream95);
	cream99cum=mean(cream91_c, cream95, cream99);
	cream03cum=mean(cream91_c, cream95, cream99, cream03);
	cream07cum=mean(cream91_c, cream95, cream99, cream03, cream07);
	cream11cum=mean(cream91_c, cream95, cream99, cream03, cream07, cream11);
	
	crmch91cum=crmch91;
	crmch95cum=mean(crmch91, crmch95);
	crmch99cum=mean(crmch91, crmch95, crmch99);
	crmch03cum=mean(crmch91, crmch95, crmch99, crmch03);
	crmch07cum=mean(crmch91, crmch95, crmch99, crmch03, crmch07);
	crmch11cum=mean(crmch91, crmch95, crmch99, crmch03, crmch07, crmch11);
	
	otch91cum=otch91;
	otch95cum=mean(otch91, otch95);
	otch99cum=mean(otch91, otch95, otch99);
	otch03cum=mean(otch91, otch95, otch99, otch03);
	otch07cum=mean(otch91, otch95, otch99, otch03, otch07);
	otch11cum=mean(otch91, otch95, otch99, otch03, otch07, otch11);
	
	but91cum=but91;
	but95cum=mean(but91, but95);
	but99cum=mean(but91, but95, but99);
	but03cum=mean(but91, but95, but99, but03);
	but07cum=mean(but91, but95, but99, but03, but07);
	but11cum=mean(but91, but95, but99, but03, but07, but11_c);

	/*** Master Loop ***/
	/* Do-loop over the time periods */
	do i=1 to dim (irt)-1;
		interval=i;

		/* Initialize timevar indicators and time period exposure indicators to 0 */
		do j=1 to dim (tv);
			tv{j}=0;
			period{j}=0;
		end;

		/* Set current timevar indicator and time period exposure indicator to 1 */
		tv{i}=1;
		period{i}=1;
		periodp=i;
		
		call missing (XXXX);
		
		/* Get all colorectal cancer */
		%getevent(colorectal);
		
		%getevent(coloncancer);
        %getevent(rectalcancer);
        %getevent(prox);
	    %getevent(distal);

		
		/*** Define Early-onset colorectal cancer, age cut off =50 ***/
		
			/* Person time for early-onset CRC: considering censor at age 50 */
			dt_CRC50=0;
			t_CRC50=irt{i+1}-irt{i};

			if irt{i}< (birthday+600) <=irt{i+1} then
				do;
					t_CRC50=min((irt{i+1}-irt{i}),(birthday+600-irt(i)));
				end;

			if colorectal=1 and irt{i}<dtdxcrc<=irt{i+1} and agedx lt 50 then
				do;
					dt_CRC50=1;
					t_CRC50=dtdxcrc-irt{i};
				end;

			if irt{i} le dtdth lt irt{i+1} then
				t_CRC50=min(t_CRC50, dtdth-irt{i});

if (birthday+600)< =irt{i} then t_CRC50=0;

			/* Add dt_Colon50 and dt_Rectal50 */
			dt_Colon50=0;

			if coloncancer=1 and irt{i}<dtdxcrc<=irt{i+1} and agedx lt 50 then
				do;
					dt_Colon50=1;
				end;

			dt_Rectal50=0;

			if rectalcancer=1 and irt{i}<dtdxcrc<=irt{i+1} and agedx lt 50 then
				do;
					dt_Rectal50=1;
				end;
				
				
				/* Person time for early-onset CRC: considering censor at age 55 */
			dt_CRC55=0;
			t_CRC55=irt{i+1}-irt{i};

			if irt{i}< (birthday+660) <=irt{i+1} then
				do;
					t_CRC55=min((irt{i+1}-irt{i}),(birthday+660-irt(i)));
				end;

			if colorectal=1 and irt{i}<dtdxcrc<=irt{i+1} and agedx lt 55 then
				do;
					dt_CRC55=1;
					t_CRC55=dtdxcrc-irt{i};
				end;

			if irt{i} le dtdth lt irt{i+1} then
				t_CRC55=min(t_CRC55, dtdth-irt{i});

if (birthday+660)< =irt{i} then t_CRC55=0;

			/* Add dt_Colon55 and dt_Rectal55 */
			dt_Colon55=0;

			if coloncancer=1 and irt{i}<dtdxcrc<=irt{i+1} and agedx lt 55 then
				do;
					dt_Colon55=1;
				end;

			dt_Rectal55=0;

			if rectalcancer=1 and irt{i}<dtdxcrc<=irt{i+1} and agedx lt 55 then
				do;
					dt_Rectal55=1;
				end;
				
		/*Heterogeneity for colon and rectal*/
		hetero_type=0;

		if coloncancer=1 and irt{i}<dtdxcrc<=irt{i+1} then
			do;
				hetero_type=1;
			end;

		if rectalcancer=1 and irt{i}<dtdxcrc<=irt{i+1} then
			do;
				hetero_type=2;
			end;

			/* Heterogeneity(%subtype) for age 50 */
			hetero_50=0;

			if colorectal=1 and irt{i}<dtdxcrc<=irt{i+1} and agedx lt 50 then
				do;
					hetero_50=1;
				end;

			if colorectal=1 and irt{i}<dtdxcrc<=irt{i+1} and agedx ge 50 then
				do;
					hetero_50=2;
				end;
				
			/* Heterogeneity(%subtype) for age 55 */
			hetero_55=0;

			if colorectal=1 and irt{i}<dtdxcrc<=irt{i+1} and agedx lt 55 then
				do;
					hetero_55=1;
				end;

			if colorectal=1 and irt{i}<dtdxcrc<=irt{i+1} and agedx ge 55 then
				do;
					hetero_55=2;
				end;

         /*person time for later-onset CRC: considering censor at age 50*/
                dt_CRCge50=0;
                t_CRCge50=0;
                        if irt{i}< (birthday+600) <=irt{i+1} and dt_CRC50=0 then
                                   do;
                                   t_CRCge50=min((irt{i+1}-irt{i}),(irt{i+1}-birthday-600));
                        end;

                                if (birthday+600) <=  irt{i} then
                                do;


                                  t_CRCge50=irt{i+1}-irt{i};
        end;


                if colorectal=1 and irt{i}<dtdxcrc<=irt{i+1} and agedx >= 50 then
                           do;
                                dt_CRCge50=1;
                                t_CRCge50=min((dtdxcrc-600-birthday),(dtdxcrc-irt{i}));
                                                end;

                if irt{i} le dtdth lt irt{i+1} and irt{i+1} >= (birthday+600) then
                          t_CRCge50=min(irt{i+1}-600-birthday, dtdth-irt{i});
                         
				
			/* Greater than 50, CRC
			dt_CRCge50=dt_colorectal;
			t_CRCge50=t_colorectal;

			if agedx lt 50 and agedx gt 0 then
				dt_CRCge50=0;*/

		/*** Start to define main exposure ***/
		
		/* All calcium intake */
		calc=calca{i};
		calccum=calccuma{i};

		/* Dietary calcium intake */
		diet_calc=diet_calca{i};
		diet_calccum=diet_calccuma{i};

		/* Dairy calcium intake */
		dcalc=dcalca{i};
		dcalccum=dcalccuma{i};
		
		/* Non-Dairy Dietary calcium intake */
		ndd=ndda{i};
		nddcum=nddcuma{i};
		
		/* Supplmental calcium intake */
		supp_calc=supp_calca{i};
		supp_calccum=supp_calccuma{i};

/* dairy foods */
skimcon= skim_d {i}; 
skimcum= skimcuma {i}; 
yogcon= yog_d{i}; 
yogcum= yogcuma {i}; 
wholecon= whole_d{i}; 
wholecum= wholecuma {i}; 
icecon= ice_d{i}; 
icecum= icecuma {i}; 
cotchcon= cot_d{i}; 
cotchcum= cotchcuma {i}; 
shercon= sher_d{i};
shercum= shercuma {i};  
creamcon= crea_d{i}; 
creamcum= creamcuma{i}; 
crmchcon= crm_d{i}; 
crmchcum= crmchcuma{i}; 
otchcon= otch_d{i}; 
otchcum= otchcuma{i}; 
butcon= but_d{i}; 
butcum= butcuma{i}; 

/*cumulative intake*/
low_fat=sum(skimcum, yogcum, cotchcum, shercum);
high_fat=sum(wholecum, icecum);
crm_ch=sum(creamcum, crmchcum, otchcum); 
high_fat_com=sum(high_fat, crm_ch);
total_fat=sum(low_fat,high_fat,crm_ch);
cheese=sum(cotchcum,crmchcum, otchcum);

milk3cum=sum(wholecum,skimcum);
yog3cum=yogcum;
cheese3cum=cheese;

calc3cum=calccum;
diet_calc3cum=diet_calccum;
supp_calc3cum=supp_calccum;
dcalc3cum=dcalccum;

		
		/*** Start to define covariates ***/

		/*** Age ***/
		agemo=irt{i}-birthday;
		ageyr=agemo/12;
		agedx=(dtdxcrc-birthday)/12;

		if 0<ageyr<30 then
			agegrp=1;
		else if 30<=ageyr<35 then
			agegrp=2;
		else if 35<=ageyr<40 then
			agegrp=3;
		else if 40<=ageyr<45 then
			agegrp=4;
		else if 45<=ageyr<50 then
			agegrp=5;
		else if ageyr>=50    then
			agegrp=6;
		else agegrp=7;

		/*** BMI ***/
		
		/* Set impossible value to missing*/
		if bmia{i}<10 then bmia{i}=.;
		
		bmi89cum =bmi89;
		bmi91cum =mean(bmi89, bmi91);
		bmi93cum =mean(bmi89, bmi91, bmi93);
		bmi95cum =mean(bmi89, bmi91, bmi93, bmi95);
		bmi97cum =mean(bmi89, bmi91, bmi93, bmi95, bmi97);
		bmi99cum =mean(bmi89, bmi91, bmi93, bmi95, bmi97, bmi99);
		bmi01cum =mean(bmi89, bmi91, bmi93, bmi95, bmi97, bmi99, bmi01);
		bmi03cum =mean(bmi89, bmi91, bmi93, bmi95, bmi97, bmi99, bmi01, bmi03);
		bmi05cum =mean(bmi89, bmi91, bmi93, bmi95, bmi97, bmi99, bmi01, bmi03, bmi05);
		bmi07cum =mean(bmi89, bmi91, bmi93, bmi95, bmi97, bmi99, bmi01, bmi03, bmi05, bmi07);
		bmi09cum =mean(bmi89, bmi91, bmi93, bmi95, bmi97, bmi99, bmi01, bmi03, bmi05, bmi07, bmi09);
		bmi11cum =mean(bmi89, bmi91, bmi93, bmi95, bmi97, bmi99, bmi01, bmi03, bmi05, bmi07, bmi09, bmi11);
		bmi13cum =mean(bmi89, bmi91, bmi93, bmi95, bmi97, bmi99, bmi01, bmi03, bmi05, bmi07, bmi09, bmi11, bmi13);

		bmi=bmia{i};
		bmicum=bmicuma{i};
		
		if bmicum=. then bmicum=24.115; /*set missing to median*/

		/*** Diabetes ***/
		if i>1 then
			do;
				if dba{i-1}=1 or dba{i}=1 then
					dba{i}=1;
				else dba{i}=0;
			end;

		db=dba{i};

		/*** Cumulative family history of cancer ***/
		if i>1 then
			do;
				if cafha{i-1}=1 or cafha{i}=1 then
					cafha{i}=1;
				else cafha{i}=0;
			end;

		cafh=cafha{i};

		/*** Cumulative family history of CRC ***/
		if i>1 then
			do;
				if crcfha{i-1}=1 or crcfha{i}=1 then
					crcfha{i}=1;
				else crcfha{i}=0;
			end;

		crcfh=crcfha{i};

		/*** Cumulative family history of Diabetes ***/
		if i>1 then
			do;
				if dbfha{i-1}=1 or dbfha{i}=1 then
					dbfha{i}=1;
				else dbfha{i}=0;
			end;

		dbfh=dbfha{i};


		/*** Physical exam ***/
		phexam=phexama{i};

		if phexam in (1,2) then phexam=1;  /*combine for screening and for symptoms*/
		else phexam=0;

		/*** Previous mammagram ***/
		mam=mama{i};

		if mam=. then
			mam=0;

		/*** History of endoscopy, derived ***/
		/* carry back endo91 one cycle */
		endo=endoa{i};
		endosx=endosxa{i};
		endoall=endoalla{i};
		endocarry=endocarrya{i};
		symptomcarry=sxcarrya{i};
		screencarry=sccarrya{i};

		/*** Regular use of aspirin ***/
		if i>1 then
			do;
				/*carry forward, decided to use this instead of one cycle*/
				if regaspa{i}=. then
					regaspa{i}=regaspa{i-1};

			end;

		regasp=regaspa{i}-1;

		if regasp=. then
			regasp=0;

		/*** Regular use of NSAID ***/
		if i>1 then
			do;
				if nsaida{i}=. then
					nsaida{i}=nsaida{i-1};
			end;

		nsaid=nsaida{i}-1;

		if nsaid=. then
			nsaid=0;

		/*** Current Multivitamin ***/
		mvt=mvta{i};
		if mvt=. then mvt=0;

		/*** Alcohol Intake ***/
		if i>1 then
			do;
				if alcoa{i}=. then
					alcoa{i}=alcoa{i-1};
			end;
		
		alco91ncum=alco91n;
		alco95ncum=mean(alco91n, alco95n);
		alco99ncum=mean(alco91n, alco95n, alco99n);
		alco03ncum=mean(alco91n, alco95n, alco99n, alco03n);
		alco07ncum=mean(alco91n, alco95n, alco99n, alco03n, alco07n);
		alco11ncum=mean(alco91n, alco95n, alco99n, alco03n, alco07n, alco11n);
		
		alco=alcoa{i};
		alcocum=alcocuma{i};	/*use this*/

		/*** Smoking ***/
		if i>1 then
			do;
				if pckyra{i} in (.,999) then
					pckyra{i}=pckyra{i-1};
			end;
		pckyr=pckyra{i};

		if pckyr=998 then pckyr=0; /*never*/

		if pckyr=999 then pckyr=0; /*Set missing to median and median=0*/
		
		pckgrp=.;

		if pckyr=0 then
			pckgrp=1;  /*never*/
		else if 0<pckyr<5 then
			pckgrp=2;
		else if 5=<pckyr<20 then
			pckgrp=3;
		else if 20=<pckyr<40 then
			pckgrp=4;
		else if 40=<pckyr<998 then
			pckgrp=5;

		/*** Fiber Intake ***/
		if i>1 then
			do;
				if fibera{i}=. then
					fibera{i}=fibera{i-1};
			end;
		
		aofib91cum=aofib91a;
		aofib95cum=mean(aofib91a, aofib95a);
		aofib99cum=mean(aofib91a, aofib95a, aofib99a);
		aofib03cum=mean(aofib91a, aofib95a, aofib99a, aofib03a);
		aofib07cum=mean(aofib91a, aofib95a, aofib99a, aofib03a, aofib07a);
		aofib11cum=mean(aofib91a, aofib95a, aofib99a, aofib03a, aofib07a, aofib11a);
		
		fiber=fibera{i};
		fibercum=fibercuma{i};

        /*** Vitamin D Intake ***/
		if i>1 then
			do;
				if vitda{i}=. then
					vitda{i}=vitda{i-1};
			end;
		
		vitd91cum=vitd91a;
		vitd95cum=mean(vitd91a, vitd95a);
		vitd99cum=mean(vitd91a, vitd95a, vitd99a);
		vitd03cum=mean(vitd91a, vitd95a, vitd99a, vitd03a);
		vitd07cum=mean(vitd91a, vitd95a, vitd99a, vitd03a, vitd07a);
		vitd11cum=mean(vitd91a, vitd95a, vitd99a, vitd03a, vitd07a, vitd11a);
	
		vitd=vitda{i};
		vitdcum=vitdcuma{i};
				
		/*** Total calories ***/
		if i>1 then
			do;
				if caloriea{i}=. then
					caloriea{i}=caloriea{i-1};
			end;
		
		calor91cum=calor91n;
		calor95cum=mean(calor91n, calor95n);
		calor99cum=mean(calor91n, calor95n, calor99n);
		calor03cum=mean(calor91n, calor95n, calor99n, calor03n);
		calor07cum=mean(calor91n, calor95n, calor99n, calor03n, calor07n);
		calor11cum=mean(calor91n, calor95n, calor99n, calor03n, calor07n, calor11n);
		
		calorie=caloriea{i};
		caloriecum=caloriecuma{i};

		/*** Folate Intake ***/
		if i>1 then
			do;
				if folatea{i}=. then
					folatea{i}=folatea{i-1};
			end;

		fol91cum=fol91a;
		fol95cum=mean(fol91a, fol95a);
		fol99cum=mean(fol91a, fol95a, fol9899a);
		fol03cum=mean(fol91a, fol95a, fol9899a, fol9803a);
		fol07cum=mean(fol91a, fol95a, fol9899a, fol9803a, fol9807a);
		fol11cum=mean(fol91a, fol95a, fol9899a, fol9803a, fol9807a, fol9811a);

		folate=folatea{i};
		folatecum=folatecuma{i};

		/*** AHEI score ***/
		if i>1 then
			do;
				if naheia{i}=. then
					naheia{i}=naheia{i-1};
			end;
		
		nahei91cum=ahei2010_noETOH91;
		nahei95cum=mean(ahei2010_noETOH91, ahei2010_noETOH95);
		nahei99cum=mean(ahei2010_noETOH91, ahei2010_noETOH95, ahei2010_noETOH99);
		nahei03cum=mean(ahei2010_noETOH91, ahei2010_noETOH95, ahei2010_noETOH99, ahei2010_noETOH03);
		nahei07cum=mean(ahei2010_noETOH91, ahei2010_noETOH95, ahei2010_noETOH99, ahei2010_noETOH03, ahei2010_noETOH07);
		nahei11cum=mean(ahei2010_noETOH91, ahei2010_noETOH95, ahei2010_noETOH99, ahei2010_noETOH03, ahei2010_noETOH07, ahei2010_noETOH11);

		naheicum=naheicuma{i};
		nahei=naheia{i};

		/*** Red and processed meat ***/
		
		rpmeat91scum=rpmeats91;
		rpmeat95scum=mean(rpmeats91, rpmeats95);
		rpmeat99scum=mean(rpmeats91, rpmeats95, rpmeats99);
		rpmeat03scum=mean(rpmeats91, rpmeats95, rpmeats99, rpmeats03);
		rpmeat07scum=mean(rpmeats91, rpmeats95, rpmeats99, rpmeats03, rpmeats07);
		rpmeat11scum=mean(rpmeats91, rpmeats95, rpmeats99, rpmeats03, rpmeats07, rpmeats11);
	
		rpmeatscum=rpmeatscuma{i};
		rpmeats=rpmeatsa{i};
		
		if rpmeatscum=. then rpmeatscum=0.8343; /*set missing to median*/
	
		/*** Physical activity in MET ***/

		act89cum=act89m;
		act91cum=mean(act89m, act91m);
		act97cum=mean(act89m, act91m, act97m);
		act01cum=mean(act89m, act91m, act97m, act01m);
		act05cum=mean(act89m, act91m, act97m, act01m, act05m);
		act09cum=mean(act89m, act91m, act97m, act01m, act05m, act09m);
		act13cum=mean(act89m, act91m, act97m, act01m, act05m, act09m, act13m);
		
		actm=actma{i};
		actmcum=actmcuma{i};

		if actmcum=. then actmcum=14.93; /*set missing to median*/
		
		/*** Postmenopausal hormone use ***/

		if dmnp{i}=1 or  hor{i}=1 then
			pmh_mn=1;

		if dmnp{i}=2 and hor{i}=2 then
			pmh_mn=2;

		if dmnp{i}=2 and hor{i}=3 then
			pmh_mn=3;

		if dmnp{i}=2 and hor{i}=4 then
			pmh_mn=4;

		if dmnp{i}=3 then pmh_mn=5;  /*dubious finally count to pre*/

		if dmnp{i} in (4,5) or (hor{i}=0 or hor{i}=6 or hor{i}=5) then pmh_mn=9;  /*revise to add 5 compared to NHS*/
		select(pmh_mn);
			when (1,5) pmh=1;
			when (2) pmh=2;
			when (3) pmh=3;
			when (4) pmh=4;
			otherwise pmh=5;
		end;

		pmh_nopast=pmh;

		if pmh_nopast=4 then
			pmh_nopast=3;

		/*** Inflammatory Bowel Disease ***/
		
		if i>1 then
			do;
				if ucola{i-1}=1 or ucola{i}=1 then
					ucola{i}=1;
				else ucola{i}=0;
		end;
			
		ucol=ucola{i};
		
		/*** Colon Polyp ***/
		cpol=cpola{i};

		/*** Exclusions start here ***/
		/* because the calcium variable started from 1991 (i=2) */
		if i=2 then
			do;
				%exclude(birthday eq .);
				%exclude(exrec eq 1);
				%exclude(age91 le 0);
				%exclude(0 lt dtdth le irt91);
				%exclude(0 lt dtdxcrc le irt91);
				%exclude(calor91n lt 600);
				%exclude(calor91n gt 3500);
				%exclude(calc91a eq .);
				%exclude(ucol91 eq 1);
				%exclude(id gt 0, nodelete=t);
				%output();
			end;

		if i>2 then
			do;
				%exclude(irt{i-1} le dtdth lt irt{i});
				%exclude(irt{i-1} lt dtdxcrc le irt{i});
				%exclude(ucol eq 1);
				%exclude(id gt 0, nodelete=t);
				%output();
			end;
	end;

	%endex();
	
	keep
		id race interval birthday
		irt89 irt91 irt93 irt95 irt97 irt99 irt01 irt03 irt05 irt07 irt09 irt11 irt13 cutoff
		t89   t91   t93   t95   t97   t99   t01   t03   t05   t07   t09   t11   t13

		/* Main Exposure */
		calc      calccum
		dcalc     dcalccum
		ndd       nddcum
		supp_calc supp_calccum
		diet_calc diet_calccum
		
		calc91a calc_91a dcalc91a ndd91a supp_calc91a
/*dairy foods*/
skimcon
skimcum
yogcon
yogcum 
wholecon 
wholecum
icecon
icecum 
cotchcon 
cotchcum
shercon
shercum  
creamcon
creamcum
crmchcon
crmchcum
otchcon
otchcum
butcon 
butcum

low_fat
high_fat
crm_ch 
high_fat_com
total_fat
cheese

calc3cum
diet_calc3cum
supp_calc3cum
dcalc3cum
milk3cum
yog3cum
cheese3cum
		
		/* Covariates */
		agemo   ageyr    agegrp     agedx
		regasp  nsaid 
		cafh    db 
		phexam  endo     mam        crcfh
		endosx  endoall  endocarry  screencarry   symptomcarry
		mvt     htm      htcm
		pmh     pmh_nopast 
		alco    alcocum
		pckyr   pckgrp
		actm    actmcum
		calorie caloriecum
		folate  folatecum
		nahei   naheicum
		rpmeats rpmeatscum
		vitd       vitdcum
		fiber   fibercum
		bmi18   bmi      bmicum

		dtdth     dtdxcrc
		
		/* Master dt and t for CRC */
		dt_colorectal
		t_colorectal
		
  dt_prox   t_prox
  dt_distal t_distal
  
  colorectal
  prox
  distal
  rectalcancer
  
  dt_coloncancer  t_coloncancer
  dt_rectalcancer t_rectalcancer
		
		/* Age 50 */
		 dt_CRC50  dt_Colon50   dt_Rectal50  dt_CRCge50
		 t_CRC50                             t_CRCge50
		 
		 dt_CRC55  dt_Colon55   dt_Rectal55 
		 t_CRC55                            
		
		hetero_type
		hetero_50
		hetero_55

	;
	/* Calcium variable started from 1991 (i=2) */
	if interval>=2;
run;


proc sort data=nhs2;
	by interval id;
run;


/*total calcium*/
proc rank data=nhs2  groups=3  out=nhs2;
var    calc3cum  diet_calc3cum  supp_calc3cum  dcalc3cum nddcum;
ranks  calc3cumq diet_calc3cumq supp_calc3cumt dcalc3cumq nddcumq;
run;

/*dairy foods - total dairy, low fat dairy, high fat dairy*/
proc rank data=nhs2  groups=3  out=nhs2;
var  low_fat high_fat crm_ch high_fat_com total_fat milk3cum yog3cum cheese3cum;
ranks  low_fatq high_fatq crm_chq high_fat_comq total_fatq milk3cumq yog3cumq cheese3cumq;
run;


data nhs2;
	set nhs2 end=_end_;
	
	/*** Set the lowest group as reference ***/
	array qvar1 calccumq diet_calccumq supp_calccumt dcalccumq calc3cumq diet_calc3cumq supp_calc3cumt dcalc3cumq nddcumq low_fatq high_fatq crm_chq high_fat_comq total_fatq milk3cumq yog3cumq cheese3cumq;

	do over qvar1;
		qvar1=qvar1+1;
	end;
	
	/*** Manually rank the total calcium, 4 groups ***/
	if calccum>=1500 then calccumq=4;
	else if 1000<=calccum<1500 then calccumq=3;
	else if 750<=calccum<1000 then calccumq=2;
	else if 0<=calccum<750 then calccumq=1;
	
	/*** Manually rank the total calcium, 3 groups ***/
	calc1cum=calccum;
	
	if calc1cum>=1400 then calc1cumq=3;
	else if 1000<=calc1cum<1400 then calc1cumq=2;
	else if 0<=calc1cum<1000 then calc1cumq=1;
	
	/*** Manually rank the dietary calcium, 3 groups ***/
	if diet_calccum>=800 then diet_calccumq=3;
	else if 600<=diet_calccum<800 then diet_calccumq=2;
	else if 0<=diet_calccum<600 then diet_calccumq=1;
	
	/*** Manually rank the Supplemental calcium, 3 groups ***/
	if supp_calccum>=800 then supp_calccumt=3;
	else if 600<=supp_calccum<800 then supp_calccumt=2;
	else if 0<=supp_calccum<600 then supp_calccumt=1;
	
	/*** Manually rank the dairy calcium, 3 groups ***/
	if dcalccum>=800 then dcalccumq=3;
	else if 600<=dcalccum<800 then dcalccumq=2;
	else if 0<=dcalccum<600 then dcalccumq=1;
	
/*dairy foods*/
if 0<=wholecum<1/30 then wholecumq=1;
else if 1/30<=wholecum<3/30 then wholecumq=2;
else if 3/30<=wholecum<2/7 then wholecumq=3;
else if wholecum>=2/7 then wholecumq=4;

if 0<=icecum<1/30 then icecumq=1;
else if 1/30<=icecum<3/30 then icecumq=2;
else if 3/30<=icecum<2/7 then icecumq=3;
else if icecum>=2/7 then icecumq=4;

if 0<=creamcum<1/30 then creamcumq=1;
else if 1/30<=creamcum<3/30 then creamcumq=2;
else if 3/30<=creamcum<2/7 then creamcumq=3;
else if creamcum>=2/7 then creamcumq=4;

if 0<=shercum<1/30 then shercumq=1;
else if 1/30<=shercum<3/30 then shercumq=2;
else if 3/30<=shercum<2/7 then shercumq=3;
else if shercum>=2/7 then shercumq=4;

if 0<=yogcum<1/30 then yogcumq=1;
else if 1/30<=yogcum<3/30 then yogcumq=2;
else if 3/30<=yogcum<2/7 then yogcumq=3;
else if yogcum>=2/7 then yogcumq=4;

if 0<=skimcum<1/7 then skimcumq=1;
else if 1/7<=skimcum<4/7 then skimcumq=2;
else if 4/7<=skimcum<1.4 then skimcumq=3;
else if skimcum>=1.4 then skimcumq=4;

if 0<=cheese<1/7 then cheeseq=1;
else if 1/7<=cheese<4/7 then cheeseq=2;
else if 4/7<=cheese<1.4 then cheeseq=3;
else if cheese>=1.4 then cheeseq=4;

milkcum=sum(wholecum,skimcum);
if 0<=milkcum<1/7 then milkcumq=1;
else if 1/7<=milkcum<4/7 then milkcumq=2;
else if 4/7<=milkcum<1.4 then milkcumq=3;
else if milkcum>=1.4 then milkcumq=4;

o_dairy=sum(icecum, creamcum, shercum);
if 0<=o_dairy<1/30 then o_dairyq=1;
else if 1/30<=o_dairy<3/30 then o_dairyq=2;
else if 3/30<=o_dairy<2/7 then o_dairyq=3;
else if o_dairy>=2/7 then o_dairyq=4;


	
	/*for continuous analyses: 
	per 300 mg/day*/
	calccum_cont = calccum/300;
	calc1cum_cont = calc1cum/300;
	calc3cum_cont = calc3cum/300;
		
	diet_calccum_cont = diet_calccum/300;
	supp_calccum_cont = supp_calccum/300;
	dcalccum_cont = dcalccum/300;
	
	diet_calc3cum_cont = diet_calc3cum/300;
	supp_calc3cum_cont = supp_calc3cum/300;
	dcalc3cum_cont = dcalc3cum/300;
	
	nddcum_cont = nddcum/300;
	
	/*** Create global indicator variables ***/

	/*** Main exposure ***/
	%indic3(vbl=calccumq,		prefix=calccumq,		min=2,	max=4,	reflev=1,	missing=.,	usemiss=0);
	%indic3(vbl=calc1cumq,		prefix=calc1cumq,		min=2,	max=3,	reflev=1,	missing=.,	usemiss=0);
	%indic3(vbl=calc3cumq,		prefix=calc3cumq,		min=2,	max=3,	reflev=1,	missing=.,	usemiss=0);

	%indic3(vbl=diet_calccumq,	prefix=diet_calccumq,	min=2,	max=3,	reflev=1,	missing=.,	usemiss=0);
	%indic3(vbl=supp_calccumt,	prefix=supp_calccumt,	min=2,	max=3,	reflev=1,	missing=.,	usemiss=0);
	%indic3(vbl=dcalccumq,	    prefix=dcalccumq,	    min=2,	max=3,	reflev=1,	missing=.,	usemiss=0);
	
	%indic3(vbl=diet_calc3cumq,	prefix=diet_calc3cumq,	min=2,	max=3,	reflev=1,	missing=.,	usemiss=0);
	%indic3(vbl=supp_calc3cumt,	prefix=supp_calc3cumt,	min=2,	max=3,	reflev=1,	missing=.,	usemiss=0);
	%indic3(vbl=dcalc3cumq,  	prefix=dcalc3cumq,	    min=2,	max=3,	reflev=1,	missing=.,	usemiss=0);
	%indic3(vbl=nddcumq,	    prefix=nddcumq,	        min=2,	max=3,	reflev=1,	missing=.,	usemiss=0);
	
  /*dairy foods*/
%indic3(vbl= low_fatq,       prefix= low_fatq,      min=2, max=3, reflev=1,missing= . ,usemiss=0);
%indic3(vbl= high_fatq,      prefix= high_fatq,     min=2, max=3, reflev=1,missing= . ,usemiss=0);
%indic3(vbl= crm_chq,        prefix= crm_chq,       min=2, max=3, reflev=1,missing= . ,usemiss=0);
%indic3(vbl= total_fatq,     prefix= total_fatq,    min=2, max=3, reflev=1,missing= . ,usemiss=0);
%indic3(vbl= high_fat_comq,  prefix= high_fat_comq, min=2, max=3, reflev=1,missing= . ,usemiss=0);

%indic3(vbl= milkcumq, prefix= milkcumq, min=2, max=4, reflev=1,missing= . ,usemiss=0);
%indic3(vbl= yogcumq, prefix=yogcumq, min=2, max=4, reflev=1,missing= . ,usemiss=0);

%indic3(vbl= milk3cumq, prefix= milk3cumq, min=2, max=3, reflev=1,missing= . ,usemiss=0);
%indic3(vbl= yog3cumq,  prefix=yog3cumq,   min=2, max=3, reflev=1,missing= . ,usemiss=0);
%indic3(vbl= cheese3cumq,  prefix=cheese3cumq,   min=2, max=3, reflev=1,missing= . ,usemiss=0);

%indic3(vbl= o_dairyq, prefix= o_dairyq, min=2, max=4, reflev=1,missing= . ,usemiss=0);
%indic3(vbl= skimcumq, prefix=skimcumq, min=2, max=4, reflev=1,missing= . ,usemiss=0);
%indic3(vbl= wholecumq, prefix= wholecumq, min=2, max=4, reflev=1,missing= . ,usemiss=0);
%indic3(vbl= icecumq, prefix=icecumq, min=2, max=4, reflev=1,missing= . ,usemiss=0);
%indic3(vbl= shercumq, prefix=shercumq, min=2, max=4, reflev=1,missing= . ,usemiss=0);
%indic3(vbl= creamcumq, prefix=creamcumq, min=2, max=4, reflev=1,missing= . ,usemiss=0);
%indic3(vbl= cheeseq, prefix=cheeseq, min=2, max=4, reflev=1,missing= . ,usemiss=0);


	/*** Covariates ***/
	%indic3(vbl=pmh, prefix=pmh, min=2, max=4, reflev=1, missing=5, usemiss=1,
			label1='premenopause',
			label2='pmh neveruse',
			label3='pmh curr use',
			label4='pmh past use');
			
	%indic3(vbl=pmh_nopast, prefix=pmh_nopast, min=2, max=3, reflev=1, missing=5, usemiss=1,
			label1='premenopause',
			label2='pmh neveruse',
			label3='pmh curr/past use');

	if 0<bmi<25 then bmi25=0;
	else if bmi>=25 then bmi25=1;
	
	if 0<bmi<30 then bmi30=0;
	else if bmi>=30 then bmi30=1;

run;



/*** Assign median value to categorical variables ***/

/* This macro assigns median both by interval and by overall, trend variable ending with 1 is the overall trend, */

/* Quintile */
%median (nhs2, calccumq,       calccumq,      interval, calccum,       calccumtrd,       calccumtrd1       );
%median (nhs2, calc1cumq,      calc1cumq,     interval, calc1cum,      calc1cumtrd,      calc1cumtrd1      );
%median (nhs2, calc3cumq,      calc3cumq,     interval, calc3cum,      calc3cumtrd,      calc3cumtrd1      );

%median (nhs2, diet_calccumq,  diet_calccumq, interval, diet_calccum,  diet_calccumtrd,  diet_calccumtrd1  );
%median (nhs2, supp_calccumt,  supp_calccumt, interval, supp_calccum,  supp_calccumtrd,  supp_calccumtrd1  );
%median (nhs2, dcalccumq,  dcalccumq, interval, dcalccum,  dcalccumtrd,  dcalccumtrd1  );
%median (nhs2, diet_calc3cumq,  diet_calc3cumq, interval, diet_calc3cum,  diet_calc3cumtrd,  diet_calc3cumtrd1  );
%median (nhs2, supp_calc3cumt,  supp_calc3cumt, interval, supp_calc3cum,  supp_calc3cumtrd,  supp_calc3cumtrd1  );
%median (nhs2, dcalc3cumq,  dcalc3cumq, interval, dcalc3cum,  dcalc3cumtrd,  dcalc3cumtrd1  );
%median (nhs2, nddcumq,  nddcumq, interval, nddcum,  nddcumtrd,  nddcumtrd1  );

/*dairy foods*/
%median (nhs2, low_fatq,  low_fatq, interval, low_fat,  low_fattrd,  low_fattrd1  );
%median (nhs2, high_fatq,  high_fatq, interval, high_fat,  high_fattrd,  high_fattrd1  );
%median (nhs2, crm_chq,  crm_chq, interval, crm_ch,  crm_chtrd,  crm_chtrd1  );
%median (nhs2, total_fatq,  total_fatq, interval, total_fat,  total_fattrd,  total_fattrd1  );
%median (nhs2, high_fat_comq,  high_fat_comq, interval, high_fat_com,  high_fat_comtrd,  high_fat_comtrd1  );

%median (nhs2, milkcumq,  milkcumq, interval, milkcum,  milkcumtrd,  milkcumtrd1  );
%median (nhs2, yogcumq,  yogcumq, interval, yogcum,  yogcumtrd,  yogcumtrd1  );
%median (nhs2, milk3cumq,  milk3cumq, interval, milk3cum,  milk3cumtrd,  milk3cumtrd1  );
%median (nhs2, yog3cumq,  yog3cumq, interval, yog3cum,  yog3cumtrd,  yog3cumtrd1  );
%median (nhs2, cheese3cumq,  cheese3cumq, interval, cheese3cum,  cheese3cumtrd,  cheese3cumtrd1  );

%median (nhs2, o_dairyq,  o_dairyq, interval, o_dairy,  o_dairytrd,  o_dairytrd1  );
%median (nhs2, skimcumq,  skimcumq, interval, skimcum,  skimcumtrd,  skimcumtrd1  );
%median (nhs2, wholecumq,  wholecumq, interval, wholecum,  wholecumtrd,  wholecumtrd1  );
%median (nhs2, icecumq,  icecumq, interval, icecum,  icecumtrd,  icecumtrd1  );
%median (nhs2, shercumq,  shercumq, interval, shercum,  shercumtrd,  shercumtrd1  );
%median (nhs2, creamcumq,  creamcumq, interval, creamcum,  creamcumtrd,  creamcumtrd1  );
%median (nhs2, cheeseq,  cheeseq, interval, cheese,  cheesetrd,  cheesetrd1  );



/*** Check main exposure and case number ***/

proc freq data=nhs2;
	tables (dt_CRC50 dt_Colon50 dt_Rectal50) *interval;
run;

proc freq data=nhs2;
	table (calccumq diet_calccumq supp_calccumt calc1cumq total_fatq high_fat_comq low_fatq milk3cumq yog3cumq cheese3cumq)*dt_CRC50;
run;

proc means data=nhs2;
	where bmi25=0;
	class interval;
	var calccum;
run;

proc means data=nhs2;
	where bmi25=1;
	class interval;
	var calccum;
run;

/*** Count the unique ID number in the final dataset ***/
ods select nlevels;
proc freq data=nhs2 nlevels;
	tables id;
	title "Distinct ID in final nhs2 datafile";
run;

title;



