clear all
set more off
use "/Users/Nicholas/Desktop/China_NSB_RCCP.dta"
gen real_GDP=GDP*100000000
gen real_pop=pop*10000
gen GDPpercapita=real_GDP/real_pop
rename  PopulationDensitypersonpersq pop_density
sort city province year
 
xtset year

gen delta_GDP=(GDP-GDP[_n-1])/ GDP[_n-1] if city==city[_n-1]
gen delta_GDPpercapita= (GDPpercapita-GDPpercapita[_n-1])/ GDPpercapita[_n-1] if city==city[_n-1]
codebook city
*266 cities
codebook city if RCCP==1
*74 in RCCP
codebook city if RCCP!=1
*192 not RCCP


---------------SUMMARY STATISTICS WITH UNMATCHED DATA BY CENTRAL CHINA---------------

*TABSTAT BY YEAR 
*TSLINE FOR EACH DV?



---------------SUMMARY STATISTICS WITH UNMATCHED DATA BY REGION-------------------------
					***BEFORE***
*Just want years before 2006
preserve
drop if year>2003
tabstat GDP FAI pop unemp, by(Region)
tabstat GDPpercapita, by(Region)
graph bar (mean) GDPpercapita, over(Region) blabel(bar) ytitle(GDP per Capita (RMB)) title(Baseline Development by Region) subtitle((1996 - 2003)) caption(Pre-Treatment)


encode city, generate(citycode)

-----------------------------PARALLEL TRENDS ANALYSIS-------------------------------------------
			
			
preserve
*Generating pre-treatment for Treatment
gen pre_RCCP=0
replace pre_RCCP=1 if province=="Henan"
replace pre_RCCP=1 if province=="Shanxi"
replace pre_RCCP=1 if province=="Hunan"
replace pre_RCCP=1 if province=="Hubei"
replace pre_RCCP=1 if province=="Jiangxi"
replace pre_RCCP=1 if province=="Anhui"
drop if year>2003
xtset year
drop if pre_RCCP==0 
twoway (lpolyci delta_GDPpercapita year, ciplot(rline) blpattern(dash) blwidth(medium)) (scatter delta_GDPpercapita year, msymbol(i) sort),  yline(0) xtitle("Year") ytitle("Change in GDP per Capita") title("Testing for Parallel Trends: Treatment (1996-2003)") 
restore
*Generating pre-treatment for Control
preserve
gen pre_RCCP=0
replace pre_RCCP=1 if province=="Henan"
replace pre_RCCP=1 if province=="Shanxi"
replace pre_RCCP=1 if province=="Hunan"
replace pre_RCCP=1 if province=="Hubei"
replace pre_RCCP=1 if province=="Jiangxi"
replace pre_RCCP=1 if province=="Anhui"
drop if year>2003
xtset year
drop if pre_RCCP==1
twoway (lpolyci delta_GDPpercapita year, ciplot(rline) blpattern(dash) blwidth(medium)) (scatter delta_GDPpercapita year, msymbol(i) sort),  yline(0) xtitle("Year") ytitle("Change in GDP per Capita") title("Testing for Parallel Trends: Control (1996-2003)") 
restore
*WHAT DO I WANT TO SEE FROM REGRESSION OUTPUT TO SHOW PARALLEL TRENDS?

----------------------------------Significance Tests------------------------------------------------------------			

*TESTS?



----------------------------------1. Simple OLS------------------------------------------------------------	


	
----------------------------------2. Adding controls to OLS------------------------------------------------			

----------------------------------3. DID Estimator---------------------------------------------------------		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
----------------------------------Instrumental Variables Regressions--------------------------------------------			
preserve
drop if year<2004 
drop if year>2011

global controls unemp pop CWD RNEC industrial_output LandArea10000sqkm pop_density          
reg RCCP FAI $controls 
predict RCCP_hat
reg delta_GDP RCCP_hat $controls, r


Linear regression                                      Number of obs =    2113
                                                       F(  8,  2104) =    4.31
                                                       Prob > F      =  0.0000
                                                       R-squared     =  0.0054
                                                       Root MSE      =  .21021

-----------------------------------------------------------------------------------
                  |               Robust
        delta_GDP |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
         RCCP_hat |   .2555525   .0677228     3.77   0.000     .1227419    .3883631
            unemp |  -.0095403   .0022699    -4.20   0.000    -.0139917   -.0050888
              pop |  -.0000143   .0000197    -0.72   0.469    -.0000529    .0000243
              CWD |   .1533862    .040396     3.80   0.000      .074166    .2326065
             RNEC |     .13578   .0409832     3.31   0.001     .0554083    .2161518
industrial_output |   .0000196   5.40e-06     3.63   0.000     9.03e-06    .0000302
LandArea10000sqkm |   .0017401   .0012518     1.39   0.165    -.0007148     .004195
      pop_density |  -8.55e-06   .0000233    -0.37   0.713    -.0000542    .0000371
            _cons |   .0612627   .0418839     1.46   0.144    -.0208756    .1434009
-----------------------------------------------------------------------------------

xtset year
xtreg delta_GDP RCCP_hat $controls, fe

Fixed-effects (within) regression               Number of obs      =      2113
Group variable: year                            Number of groups   =         8

R-sq:  within  = 0.0057                         Obs per group: min =       261
       between = 0.0008                                        avg =     264.1
       overall = 0.0054                                        max =       265

                                                F(8,2097)          =      1.50
corr(u_i, Xb)  = -0.0294                        Prob > F           =    0.1513

-----------------------------------------------------------------------------------
        delta_GDP |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
         RCCP_hat |   .3109304   .1619381     1.92   0.055    -.0066457    .6285066
            unemp |  -.0107176   .0050904    -2.11   0.035    -.0207004   -.0007348
              pop |  -.0000204   .0000293    -0.70   0.485    -.0000779     .000037
              CWD |   .1852732   .0939078     1.97   0.049     .0011109    .3694355
             RNEC |   .1674392   .0946161     1.77   0.077     -.018112    .3529904
industrial_output |   .0000232   .0000121     1.92   0.055    -4.96e-07    .0000469
LandArea10000sqkm |    .001916   .0023346     0.82   0.412    -.0026625    .0064944
      pop_density |  -1.80e-06   .0000264    -0.07   0.946    -.0000536      .00005
            _cons |   .0293442   .0936125     0.31   0.754    -.1542389    .2129273
------------------+----------------------------------------------------------------
          sigma_u |    .031298
          sigma_e |  .20849895
              rho |  .02203678   (fraction of variance due to u_i)
-----------------------------------------------------------------------------------
F test that all u_i=0:     F(7, 2097) =     5.94             Prob > F = 0.0000

*WHY NOT CLUSTERING?
*HOW TO CLUSTER CITIES?
---------------------------Ashenfelter's Dip---------------------------


preserve
*this should be divived out by the two groups
gen RCCP_startyear=2004
gen tau = year-RCCP_startyear
drop if tau<-5
collapse FAI GDP, by(tau)
lowess GDP tau if tau<0, bwidth(2) nograph gen(yminus)
lowess GDP tau if tau>0, bwidth(2) nograph gen(yplus)
label var yminus "Smoothed GDP if Tau<0"
label var yplus "Smoothed GDP if Tau>0"
sort tau
tw scatter GDP tau, xline(0) ||  line yminus tau ||  line yplus tau,  title(Testing for Ashenfelter's Dip) xtitle("RCCP Treatment (Years Pre and Post)") ytitle("GDP in 100million RMB") 
*add in "if clause" for each group

lowess FAI tau if tau<0, bwidth(2) nograph gen(yminus1)
lowess FAI tau if tau>0, bwidth(2) nograph gen(yplus1)
label var yminus1 "Smoothed FAI if Tau<0"
label var yplus1 "Smoothed FAI if Tau>0"
sort tau
tw scatter FAI tau, xline(0) ||  line yminus1 tau ||  line yplus1 tau, title(Testing for Ashenfelter's Dip) xtitle("RCCP Treatment (Years Pre and Post)") ytitle("FAI in 100million RMB") 
restore

*INVESTMENT SEEMS TO TAKE OFF IN 2002, 2 YEARS BEFORE THE ANNOUNCEMENT OF THE RCCP. SPILLOVERS?




---------------------------MATCHING AND ROBUSTNESS CHECKS--------------------------------------------------
				
*Common support matching on pre-2005
preserve
drop if year>2006
collapse RCCP delta_FAI FAI percapGDP unemp pop, by(city)
pscore RCCP percapGDP unemp pop, pscore(pscore) blockid(blockid) comsup
/*
  Inferior |
  of block |      (mean) RCCP
of pscore  |         0          1 |     Total
-----------+----------------------+----------
  .0891357 |        27          5 |        32 
        .2 |       111         53 |       164 
        .4 |        16          3 |        19 
       .45 |         4          4 |         8 
        .5 |         4          7 |        11 
        .6 |         0          2 |         2 
-----------+----------------------+----------
     Total |       162         74 |       236 

*/


*Bulk of data in lower trough 

*Nearest neighbor matching
attnd RCCP percapGDP unemp pop, pscore(pscore) comsup boot reps(5) dots 


*Radius matching 
attr $ylist $treatment $controls, pscore(p) comsup boot reps($breps) dots radius(0.1)


*Kernel Matching
attk $ylist $treatment $controls, pscore(p) comsup boot reps($breps) dots

* Stratification Matching
atts $ylist $treatment $controls, pscore(p) blockid(b) comsup boot reps($breps) dots
*We have 10 blocks and this is the only one that you inlude block ID and myblock. This has to be the same
*variable name as stored before. Using controls block by block and not crossing across the 10 blocks
*/

