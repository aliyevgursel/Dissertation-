//ANALYSIS FOR CHAPTER 4
use "C:\Users\galiyev\Documents\Dissertation\Chapter 3\Analysis\DataCleaned4RegWP99.dta", replace //Using Winsorized data
sort prim_key
set more off

save Calculations, replace

*REPLACING T1 AND T2 WITH 1 IF THEY ARE > 1
*replace T1 = 1 if T1 > 1 & T1 != .
*replace T2 = 1 if T2 > 1 & T2 != .

*REPLACING A3 AND A4 WITH 1 IF THEY ARE > 1
replace A3 = 1 if A3 > 1 & A3 != .
replace A4 = 1 if A4 > 1 & A4 != .

keep if preptaxesself == 1

**************************** Generating Long Form of the Dataset ****************************
*Generating a long form of the dataset for the panel data analysis
reshape long E T A P, i(prim_key) j(scenarios)
by prim_key (scenarios), sort: replace T = T[1] if T >= . & E != .
by prim_key (scenarios), sort: replace P = P[1] if P >= . & E != .
by prim_key (scenarios), sort: replace A = A[1] if A >= . & E != .

*Generating expected penalty variable
gen double expectedpenalty = P*pcaught //THIS COEFFICIENT IS SIGNIFICANT IN SOME MODELS, BUT THE SIGN IS CHANGING DEPENDING ON THE SPECIFICATION.

*Generating interaction terms
gen double intAT = A*T //THIS INTERACTION COEFFICIENT IS NEGATIVE IN ALL MODELS, AND SIGNIFICANT IN ALL MODELS EXCEPT FOR THE GLM
gen double intAP = A*P  //THIS INTERACTION COEFFICIENT WAS NOT SIGNIFICANT IN ANY OF THE FOUR SHORTLISTED MODELS
gen double intPT = P*T //THIS INTERACTION COEFFICIENT WAS NOT SIGNIFICANT IN ANY OF THE FOUR SHORTLISTED MODELS
gen double intpcaughtT = pcaught*T //THIS INTERACTION COEFFICIENT WAS ONLY SIGNIFICANT IN XTREG MODEL. THE SIGN WAS SOMETIMES POSITIVE AND SOMETIMES NEGATIVE.
gen double Trand = T*randomtaxincrease
tab preptaxesself, m

******************************** REGRESSION MODELS WITH THE PANEL DATA ********************************
*Generating a numeric respondent id variable since xtset command doesn't work with string variables.
encode prim_key, gen(respid) 
egen id = group(prim_key)

svyset id, weight(weight)

**************************** Baseline Means ****************************
*Estimating Baseline Means for T, A and P
svy: mean T if scenarios == 0
svy: mean A if scenarios == 0
svy: mean P if scenarios == 0
svy: mean E if scenarios == 0
su E if scenario == 0

*Tabulations for Estimating the 1st, 25th, 50th, 75th and 99th percentiles for Baseline T, A and P 
svy: tab T if scenarios == 0
svy: tab A if scenarios == 0
svy: tab P if scenarios == 0
svy: tab preptaxesself if scenarios == 0
tab preptaxesself, m
tab preptaxesself if scenarios == 0

******************************** Linear Regression Models with the Panel Data ********************************
xtset id scenarios

global xlist1 calcage i.BlackAA i.Native i.Asian i.Otherrace i.hispaniclatino i.male i.married i.education i.foreignborn MTR1 i.selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed i.hheveraudited prob_deduction i.actor_more fr_never fr2 i.worthpayingtaxes taxesimportant_c taxesimportant_d

******************************** Generalized Linear Models with the Panel Data ********************************
*Papke & Wooldridge 2008  Fractional Response Model (XTGEE) with the panel data
log using InterventionEstimates, replace
*Model 11: GLM with XTGEE, but with cloglog and loglog link
*Main Model
glm E c.T##i.randomtaxincrease A P $xlist1 [pw = weight], fa(bin) link(cloglog) cluster(id) nolog
mat b = e(b)
xtgee E c.T##i.randomtaxincrease A P  $xlist1 [pw = weight], fa(bin) link(cloglog) corr(exch) robust from(b, skip) nolog //A is positive, but insig. P is negative and insig.

*Evasion rate with no intevention
margins if scenarios == 0 & e(sample)

//For Everyone & 100% Effectiveness
*Evasion rate with intervention 2, for everyone & 100% effectiveness
margins if scenarios == 0 & e(sample), at(P = 0.75) //for everyone & 100% effectiveness


*Evasion rate estimate for Intervention 1 only, for everyone & 100% effectiveness
gen int2taxincrease = (T < estT1frac) //generating a dummy variable: = 1 if perceived T less than actual, i.e., underestimates; 0 = if otherwise.)
replace int2taxincrease = . if T == . | estT1frac == .
preserve
replace randomtaxincrease = int2taxincrease
margins if scenarios == 0 & e(sample), at(T = gen(estT1/100)) //for everyone & 100% effectiveness

*Evasion rate estimate for both Interventions, for everyone & 100% effectiveness
margins if scenarios == 0 & e(sample), at(T = gen(estT1/100) P = 0.75) //for everyone & 100% effectiveness
restore
preserve

//For Only Those Who Prepare Tax Returns Themselves & 100% Effectiveness
*Evasion rate with intervention 2, for preptaxesself & 100% effectiveness
replace P = 0.75 if scenarios == 0 & e(sample) & preptaxesself == 1 //TURN ON THE REPLACEMENT, RECALCULATE, BUT THEN RESTORE.
margins if scenarios == 0 & e(sample) //margins after the replacement of P with 0.75 for preptaxesself == 1
restore
preserve

*Evasion rate estimate for Intervention 1 only, for preptaxesself & 100% effectiveness
replace randomtaxincrease = int2taxincrease if preptaxesself == 1 //TURN ON THE REPLACEMENT WHEN CALCULATING THE EFFECT OF INTERVENTION 2 IN FRM, BUT THEN RESTORE AND RE-RUN THE CODE WITHOUT IT.
replace T = estT1frac if preptaxesself == 1 //TURN ON THE REPLACEMENT, RECALCULATE, BUT THEN RESTORE.
margins if scenarios == 0 & e(sample) //margins after the replacement of T with estT1frac and randomtaxincrease with int2taxincrease for preptaxesself == 1*/

*Evasion rate estimate for both Interventions, for preptaxesself & 100% effectiveness
replace P = 0.75 if scenarios == 0 & e(sample) & preptaxesself == 1 //TURN ON THE REPLACEMENT, RECALCULATE, BUT THEN RESTORE.
margins if scenarios == 0 & e(sample) //Both interventions
restore

*Proportion of those who prepare tax returns themselves in the FRM
svy: tab preptaxesself if scenarios == 0 & e(sample)
tab preptaxesself if scenarios == 0 & e(sample)

******************************** Linear Mixed-Effect Models with the Panel Data ********************************
*Model 16: Linear Mixed-Effect Model (Random Intercepts and coefficients)
*Main model
*16_1) Linear ME model with covariance between random slope and intercept, all indep. vars
mixed E c.T##i.randomtaxincrease A P $xlist1 [pw=weight] || id: T A P, covariance(uns) nolog //All signs as expected and significant

*Evasion rate with no intevention
margins if scenarios == 0 & e(sample)

//For Everyone & 100% Effectiveness
*Evasion rate estimate for Intervention 2 only, for everyone & 100% effectiveness
margins if scenarios == 0 & e(sample), at(P = 0.75) 

preserve
*Evasion rate estimate for Intervention 1 only, for everyone & 100% effectiveness
replace randomtaxincrease = int2taxincrease //TURN ON THE REPLACEMENT WHEN CALCULATING THE EFFECT OF INTERVENTION 2 IN ME MODEL, BUT THEN RESTORE AND RE-RUN THE CODE WITHOUT IT.
margins if scenarios == 0 & e(sample), at(T = gen(estT1/100))


*Evasion rate estimate for Both Interventions, for everyone & 100% effectiveness
margins if scenarios == 0 & e(sample), at(P = 0.75 T = gen(estT1/100))
restore
preserve

//For Only Those Who Prepare Tax Returns Themselves & 100% Effectiveness
*Evasion rate with intervention 2, for preptaxesself & 100% effectiveness
replace P = 0.75 if scenarios == 0 & e(sample) & preptaxesself == 1 //TURN ON THE REPLACEMENT, RECALCULATE, BUT THEN RESTORE.
margins if scenarios == 0 & e(sample) //margins after the replacement of P with 0.75 for preptaxesself == 1
restore
preserve

*Evasion rate estimate for Intervention 1 only, for preptaxesself & 100% effectiveness
replace randomtaxincrease = int2taxincrease if preptaxesself == 1 //TURN ON THE REPLACEMENT WHEN CALCULATING THE EFFECT OF INTERVENTION 2 IN FRM, BUT THEN RESTORE AND RE-RUN THE CODE WITHOUT IT.
replace T = estT1frac if preptaxesself == 1 //TURN ON THE REPLACEMENT, RECALCULATE, BUT THEN RESTORE.
margins if scenarios == 0 & e(sample) //margins after the replacement of T with estT1frac and randomtaxincrease with int2taxincrease for preptaxesself == 1*/

*Evasion rate estimate for both Interventions, for preptaxesself & 100% effectiveness
replace P = 0.75 if scenarios == 0 & e(sample) & preptaxesself == 1 //TURN ON THE REPLACEMENT, RECALCULATE, BUT THEN RESTORE.
margins if scenarios == 0 & e(sample) //Both interventions
restore

*Proportion of those who prepare tax returns themselves in the ME model
svy: tab preptaxesself if scenarios == 0 & e(sample)
tab preptaxesself if scenarios == 0 & e(sample)

log close
clear
