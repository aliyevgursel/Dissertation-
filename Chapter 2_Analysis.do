//ANALYSIS FOR CHAPTER 2
 use "C:\Users\galiyev\Documents\Dissertation\Chapter 2\ms456\ALP_MS456_2017_01_19_04_40_42_weighted.dta", replace
 set more off
 
 *dropping a test case 65:2
 drop if prim_key == "65:2"
 
 
 *Summaries for A - perceived audit rate, P - perceived penalty rate, and T- perceived effective tax rate
tab perceivedauditrate, m
replace perceivedauditrate = "10" if perceivedauditrate == "10%"
tab perceivedauditratemagnifier, m
tab perceivedpenaltyrate, m
tab perceivedtaxrate, m
tab familyincome, m
tab familyincome_part2, m
tab familyincome familyincome_part2, m 

************************** Generating A, P and T **************************

*generating A- perceived audit rate variable
gen A = real(perceivedauditrate) //converting perceivedauditrate variable into a numeric variable
tab A perceivedauditratemagnifier, m

*replacing values with magnified audit values. Taking midpoints of the magnifier interval. Only those respondents who have inconsistent ms456_perceivedauditrate and ms456_peer
replace A = 1 if perceivedauditrate == "0" & perceivedauditratemagnifier == 6
replace A = 0.55 if perceivedauditrate == "0" & perceivedauditratemagnifier == 5
replace A = 0.0055 if perceivedauditrate == ".02" & perceivedauditratemagnifier == 3
replace A = 0.0005 if perceivedauditrate == ".05" & perceivedauditratemagnifier == 2
replace A = 0.055 if perceivedauditrate == "0.5" & perceivedauditratemagnifier == 4
replace A = 0.055 if perceivedauditrate == ".5" & perceivedauditratemagnifier == 4
replace A = 0.055 if perceivedauditrate == "1" & perceivedauditratemagnifier == 4
replace A = 0.0055 if perceivedauditrate == "1" & perceivedauditratemagnifier == 3
replace A = 0.0005 if perceivedauditrate == "1" & perceivedauditratemagnifier == 2
replace A = 0 if A == . & perceivedauditratemagnifier == 1
replace A = 0.0005 if A == . & perceivedauditratemagnifier == 2

gen P = perceivedpenaltyrate/10
gen sqrtP = sqrt(P) //transforming P to reduce skewness.
gen lnP = ln(P) //transforming P to reduce skewness.
gen T = perceivedtaxrate
gen PD = perceivedcaught

**************************** Winsorizing Penalty Rate **************************
gen wP = P
replace wP = . if P >= 500 //removing outliers above 500
gen wP1 = wP if P < 400 //removing outliers above 400
gen wP2 = wP if P < 300 //removing outliers above 300
gen wP3 = wP if P < 240 //removing outliers above 240
********************************************************************************

************************ Generating Effective Tax Rate *************************
/*There are 90 respondents for whom familyincome is not 14, but familyincome_part2 
has responses. This happened because, some respondents after responding to 
familyincome_part2, went back and changed their responses in familyincome.
To address this issue, there are three options:
1. dropping inconsistent responses (hhincome1)
2. keep as in familyincome (hhincome2)
3. keep as in familyincome_part2 (hhincome3)
*/
gen hhincome1 = familyincome
replace hhincome1 = . if familyincome < 14 & familyincome_part2 != .
replace hhincome1 = 15 if familyincome == 14 & familyincome_part2 == 2
replace hhincome1 = 16 if familyincome == 14 & familyincome_part2 == 3
replace hhincome1 = 17 if familyincome == 14 & familyincome_part2 == 4

label define hhincomeL 1 "< $5,000" 2 "$5,000 to $7,499" 3 "$7,500 to $9,999" 4 "$10,000 to $12,499" 5 "$12,500 to $14,999" 6 "$15,000 to $19,999" 7 "$20,000 to $24,999" 8 "$25,000 to $29,999" 9 "$30,000 to $34,999" 10 "$35,000 to $39,999" 11 "$40,000 to $49,999" 12 "$50,000 to $59,999" 13 "$60,000 to $74,999" 14 "$75,000 to $99,999" 15 "$100,000 to $124,999" 16 "$125,000 to $199,999" 17 "$200,000 and more"
label values hhincome1 hhincomeL

gen hhincome2 = familyincome
replace hhincome2 = 14 if familyincome == 14 &  familyincome_part2 == 1
replace hhincome2 = 15 if familyincome == 14 &  familyincome_part2 == 2
replace hhincome2 = 16 if familyincome == 14 &  familyincome_part2 == 3
replace hhincome2 = 17 if familyincome == 14 &  familyincome_part2 == 4

label values hhincome2 hhincomeL


gen hhincome3 = familyincome
replace hhincome3 = 14 if familyincome_part2 == 1
replace hhincome3 = 15 if familyincome_part2 == 2
replace hhincome3 = 16 if familyincome_part2 == 3
replace hhincome3 = 17 if familyincome_part2 == 4

label values hhincome3 hhincomeL

*generating effective tax rate variable based on hhincome
gen estT1 = .
replace estT1 = -0.2 if hhincome1 == 1
replace estT1 = 0.4 if hhincome1 == 2
replace estT1 = 0.4 if hhincome1 == 3
replace estT1 = 0.9 if hhincome1 == 4
replace estT1 = 0.9 if hhincome1 == 5
replace estT1 = 1.8 if hhincome1 == 6
replace estT1 = 2.8 if hhincome1 == 7
replace estT1 = 3.6 if hhincome1 == 8
replace estT1 = 4.8 if hhincome1 == 9
replace estT1 = 4.8 if hhincome1 == 10
replace estT1 = 6.2 if hhincome1 == 11
replace estT1 = 8.1 if hhincome1 == 12
replace estT1 = 8.1 if hhincome1 == 13
replace estT1 = 9.5 if hhincome1 == 14
replace estT1 = 12.6 if hhincome1 == 15
replace estT1 = 12.6 if hhincome1 == 16
replace estT1 = 23.8 if hhincome1 == 17

gen estT2 = .
replace estT2 = -0.2 if hhincome2 == 1
replace estT2 = 0.4 if hhincome2 == 2
replace estT2 = 0.4 if hhincome2 == 3
replace estT2 = 0.9 if hhincome2 == 4
replace estT2 = 0.9 if hhincome2 == 5
replace estT2 = 1.8 if hhincome2 == 6
replace estT2 = 2.8 if hhincome2 == 7
replace estT2 = 3.6 if hhincome2 == 8
replace estT2 = 4.8 if hhincome2 == 9
replace estT2 = 4.8 if hhincome2 == 10
replace estT2 = 6.2 if hhincome2 == 11
replace estT2 = 8.1 if hhincome2 == 12
replace estT2 = 8.1 if hhincome2 == 13
replace estT2 = 9.5 if hhincome2 == 14
replace estT2 = 12.6 if hhincome2 == 15
replace estT2 = 12.6 if hhincome2 == 16
replace estT2 = 23.8 if hhincome2 == 17

gen estT3 = .
replace estT3 = -0.2 if hhincome3 == 1
replace estT3 = 0.4 if hhincome3 == 2
replace estT3 = 0.4 if hhincome3 == 3
replace estT3 = 0.9 if hhincome3 == 4
replace estT3 = 0.9 if hhincome3 == 5
replace estT3 = 1.8 if hhincome3 == 6
replace estT3 = 2.8 if hhincome3 == 7
replace estT3 = 3.6 if hhincome3 == 8
replace estT3 = 4.8 if hhincome3 == 9
replace estT3 = 4.8 if hhincome3 == 10
replace estT3 = 6.2 if hhincome3 == 11
replace estT3 = 8.1 if hhincome3 == 12
replace estT3 = 8.1 if hhincome3 == 13
replace estT3 = 9.5 if hhincome3 == 14
replace estT3 = 12.6 if hhincome3 == 15
replace estT3 = 12.6 if hhincome3 == 16
replace estT3 = 23.8 if hhincome3 == 17

*generating marginla tax rates based on hhincome
gen MT1 = .
replace MT1 = 0 if hhincome1 < 4
replace MT1 = 0 if hhincome1 < 7 & currentlivingsituation == 1
replace MT1 = 10 if hhincome1 >= 7 & hhincome1 <= 10 & currentlivingsituation == 1
replace MT1 = 15 if hhincome1 >= 11 & hhincome1 <= 14 & currentlivingsituation == 1
replace MT1 = 25 if hhincome1 == 15 & currentlivingsituation == 1
replace MT1 = 26.5 if hhincome1 == 16 & currentlivingsituation == 1 //In this income bracket some respondents have marginal tax rate of 25%, while the others 28%. Because of that simple average of these two rates is used instead.  
replace MT1 = 28 if hhincome1 == 17 & currentlivingsituation == 1
replace MT1 = 10 if hhincome1 >= 4 & hhincome1 <= 6 & currentlivingsituation != 1
replace MT1 = 15 if hhincome1 >= 7 & hhincome1 <= 11 & currentlivingsituation != 1
replace MT1 = 25 if hhincome1 >= 12 & hhincome1 <= 14 & currentlivingsituation != 1
replace MT1 = 28 if hhincome1 >= 15 & hhincome1 <= 16 & currentlivingsituation != 1
replace MT1 = 33 if hhincome1 == 17 & currentlivingsituation != 1

gen MT2 = .
replace MT2 = 0 if hhincome2 < 4
replace MT2 = 0 if hhincome2 < 7 & currentlivingsituation == 1
replace MT2 = 10 if hhincome2 >= 7 & hhincome2 <= 10 & currentlivingsituation == 1
replace MT2 = 15 if hhincome2 >= 11 & hhincome2 <= 14 & currentlivingsituation == 1
replace MT2 = 25 if hhincome2 == 15 & currentlivingsituation == 1
replace MT2 = 26.5 if hhincome2 == 16 & currentlivingsituation == 1 //In this income bracket some respondents have marginal tax rate of 25%, while the others 28%. Because of that simple average of these two rates is used instead.  
replace MT2 = 28 if hhincome2 == 17 & currentlivingsituation == 1
replace MT2 = 10 if hhincome2 >= 4 & hhincome2 <= 6 & currentlivingsituation != 1
replace MT2 = 15 if hhincome2 >= 7 & hhincome2 <= 11 & currentlivingsituation != 1
replace MT2 = 25 if hhincome2 >= 12 & hhincome2 <= 14 & currentlivingsituation != 1
replace MT2 = 28 if hhincome2 >= 15 & hhincome2 <= 16 & currentlivingsituation != 1
replace MT2 = 33 if hhincome2 == 17 & currentlivingsituation != 1

gen MT3 = .
replace MT3 = 0 if hhincome3 < 4
replace MT3 = 0 if hhincome3 < 7 & currentlivingsituation == 1
replace MT3 = 10 if hhincome3 >= 7 & hhincome3 <= 10 & currentlivingsituation == 1
replace MT3 = 15 if hhincome3 >= 11 & hhincome3 <= 14 & currentlivingsituation == 1
replace MT3 = 25 if hhincome3 == 15 & currentlivingsituation == 1
replace MT3 = 26.5 if hhincome3 == 16 & currentlivingsituation == 1 //In this income bracket some respondents have marginal tax rate of 25%, while the others 28%. Because of that simple average of these two rates is used instead.  
replace MT3 = 28 if hhincome3 == 17 & currentlivingsituation == 1
replace MT3 = 10 if hhincome3 >= 4 & hhincome3 <= 6 & currentlivingsituation != 1
replace MT3 = 15 if hhincome3 >= 7 & hhincome3 <= 11 & currentlivingsituation != 1
replace MT3 = 25 if hhincome3 >= 12 & hhincome3 <= 14 & currentlivingsituation != 1
replace MT3 = 28 if hhincome3 >= 15 & hhincome3 <= 16 & currentlivingsituation != 1
replace MT3 = 33 if hhincome3 == 17 & currentlivingsituation != 1


*************************** Histograms for A, P and T **************************
/*main ones
hist A, percent bin(25) title("Distribution of Perceived Audit Rates") xtitle("Perceived Audit Rate (percent)") addplot(pci 0 0.7 23 0.7, lpattern(dash) lwidth(medthick)) legend(label(2 "actual audit rate") order(2)) saving(Histogram_A_with_vline, replace)
hist wP, percent bin(55) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 75 46 75, lpattern(dash) lwidth(medthick)|| pci 0 40 46 40, lcolor(red) lpattern(dash_dot) lwidth(medthick) || pci 0 20 46 20, lcolor(orange) lpattern(longdash_dot) lwidth(medthick)) legend(label(2 "fraud penalty rate") label(3 "accuracy-related penalty rate") label(4 "estimated average penalty rate") order(4 3 2)) saving(HistogramWP_with_vlineAll, replace)

hist P, percent bin(100) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 75 46 75, lpattern(dash) lwidth(medthick)) legend(label(2 "fraud penalty rate") order(2)) saving(HistogramP_with_vline75, replace)
hist P, percent bin(100) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 40 46 40, lpattern(dash_dot) lcolor(red) lwidth(medthick)) legend(label(2 "accuracy-related penalty rate (high)") order(2)) saving(HistogramP_with_vline40, replace)
hist P, percent bin(100) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 20 46 20, lpattern(longdash_dot) lcolor(orange) lwidth(medthick)) legend(label(2 "estimated average penalty rate") order(2)) saving(HistogramP_with_vline20, replace)

hist wP, percent bin(100) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 75 46 75, lpattern(dash) lwidth(medthick)) legend(label(2 "fraud penalty rate") order(2)) saving(HistogramWP_with_vline75, replace)
hist wP, percent bin(100) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 40 46 40, lpattern(dash_dot) lcolor(red) lwidth(medthick)) legend(label(2 "accuracy-related penalty rate (high)") order(2)) saving(HistogramWP_with_vline40, replace)
hist wP, percent bin(100) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 20 46 20, lpattern(longdash_dot) lcolor(orange) lwidth(medthick)) legend(label(2 "estimated average penalty rate") order(2)) saving(HistogramWP_with_vline20, replace)

twoway(histogram T, percent width(2) color(green)) (histogram estT1, percent width(2) fcolor(none) lcolor(black)), title("Distribution of Perceived and Estimated Effective Tax Rates") xtitle("Effective Tax Rate (percent)") legend(order(1 "perceived" 2 "estimated actual")) saving(HistogramT, replace)
*/
*selected main histograms with weights
gen int_weights = int(weight)
replace int_weights = 1 if weight < 1 // otherwise, will lose a lot of observations because of rounding
gen int_weights10 = int(10*weight)

hist wP [fw = int_weights], percent bin(45) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 75 46 75, lpattern(dash) lwidth(medthick)|| pci 0 40 46 40, lcolor(red) lpattern(dash_dot) lwidth(medthick) || pci 0 20 46 20, lcolor(orange) lpattern(longdash_dot) lwidth(medthick)) legend(label(2 "fraud penalty rate") label(3 "accuracy-related penalty rate (high)") label(4 "typically applied penalty rate") order(4 3 2)) saving(HistogramWP_with_vlineAllWEIGHTS, replace)
hist wP [fw = int_weights], percent bin(65) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 75 46 75, lpattern(dash) lwidth(medthick)|| pci 0 40 46 40, lcolor(red) lpattern(dash_dot) lwidth(medthick) || pci 0 20 46 20, lcolor(dark blue) lpattern(longdash_dot) lwidth(medthick)) legend(label(2 "fraud penalty rate") label(3 "accuracy-related penalty rate (high)") label(4 "typically applied penalty rate") order(4 3 2)) saving(HistogramWP_with_vlineAllWEIGHTS, replace)

/*
hist A [fw = int_weights], percent bin(25) title("Distribution of Perceived Audit Rates") xtitle("Perceived Audit Rate (percent)") addplot(pci 0 0.7 23 0.7, lpattern(dash) lwidth(medthick)) legend(label(2 "actual audit rate") order(2)) saving(Histogram_A_with_vlineWEIGHTS, replace)
hist wP [fw = int_weights], percent bin(45) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 75 46 75, lpattern(dash) lwidth(medthick)|| pci 0 40 46 40, lcolor(red) lpattern(dash_dot) lwidth(medthick) || pci 0 20 46 20, lcolor(orange) lpattern(longdash_dot) lwidth(medthick)) legend(label(2 "fraud penalty rate") label(3 "accuracy-related penalty rate (high)") label(4 "estimated average enforced penalty rate") order(4 3 2)) saving(HistogramWP_with_vlineAllWEIGHTS, replace)
hist wP [fw = int_weights], percent bin(65) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 75 46 75, lpattern(dash) lwidth(medthick)|| pci 0 40 46 40, lcolor(red) lpattern(dash_dot) lwidth(medthick) || pci 0 20 46 20, lcolor(dark blue) lpattern(longdash_dot) lwidth(medthick)) legend(label(2 "fraud penalty rate") label(3 "accuracy-related penalty rate (high)") label(4 "estimated average enforced penalty rate") order(4 3 2)) saving(HistogramWP_with_vlineAllWEIGHTS, replace)

twoway(histogram T [fw = int_weights10], percent width(2) color(green)) (histogram estT1 [fw = int_weights10], percent width(2) fcolor(none) lcolor(black)), title("Distribution of Perceived and Estimated Effective Tax Rates") xtitle("Effective Tax Rate (percent)") legend(order(1 "perceived" 2 "estimated actual")) saving(HistogramT, replace)
twoway(histogram T [fw = int_weights], percent width(2) color(green)) (histogram estT1 [fw = int_weights], percent width(2) fcolor(none) lcolor(black)), title("Distribution of Perceived and Estimated Effective Tax Rates") xtitle("Effective Tax Rate (percent)") legend(order(1 "perceived" 2 "estimated actual")) saving(HistogramT, replace)
twoway(histogram T [fw = int_weights], percent width(2) color(green)) (histogram MT1 [fw = int_weights], percent width(2) fcolor(none) lcolor(black)), title("Distribution of Perceived and Estimated Marginal Tax Rates") xtitle("Marginal Tax Rate (percent)") legend(order(1 "perceived" 2 "estimated marginal")) saving(HistogramMT1, replace)

*others
hist P, fraction bin(100) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 75 46 75, lpattern(dash) lwidth(medthick)|| pci 0 40 46 40, lcolor(red) lpattern(dash_dot) lwidth(medthick) || pci 0 20 46 20, lcolor(orange) lpattern(longdash_dot) lwidth(medthick)) legend(label(2 "fraud penalty rate") label(3 "accuracy-related penalty rate") label(4 "estimated average penalty rate") order(4 3 2)) saving(HistogramP_with_vlineAll, replace)
hist wP1, fraction bin(100) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 75 46 75, lpattern(dash) lwidth(medthick)|| pci 0 40 46 40, lcolor(red) lpattern(dash_dot) lwidth(medthick) || pci 0 20 46 20, lcolor(orange) lpattern(longdash_dot) lwidth(medthick)) legend(label(2 "fraud penalty rate") label(3 "accuracy-related penalty rate") label(4 "estimated average penalty rate") order(4 3 2)) saving(HistogramWP1_with_vlineAll, replace)
hist wP2, fraction bin(100) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 75 46 75, lpattern(dash) lwidth(medthick)|| pci 0 40 46 40, lcolor(red) lpattern(dash_dot) lwidth(medthick) || pci 0 20 46 20, lcolor(orange) lpattern(longdash_dot) lwidth(medthick)) legend(label(2 "fraud penalty rate") label(3 "accuracy-related penalty rate") label(4 "estimated average penalty rate") order(4 3 2)) saving(HistogramWP2_with_vlineAll, replace)
hist wP, fraction bin(100) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 75 46 75, lpattern(dash) lwidth(medthick)|| pci 0 20 46 20, lcolor(orange) lpattern(dash) lwidth(medthick)) legend(label(2 "fraud penalty rate") label(3 "estimated average penalty rate") order(2 3)) saving(HistogramWP_with_vline2, replace)
hist P, fraction bin(100) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 75 46 75, lpattern(dash) lwidth(medthick)|| pci 0 20 46 20, lcolor(orange) lpattern(dash) lwidth(medthick)) legend(label(2 "fraud penalty rate") label(3 "estimated average penalty rate") order(2 3)) saving(HistogramP_with_vline2, replace)

hist A, fraction bin(25) title("Distribution of Perceived Audit Rates") xtitle("Perceived Audit Rate (percent)") saving(HistogramA, replace)
hist P, fraction bin(100) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") saving(HistogramP, replace)
hist wP, fraction bin(100) title("Distribution of Perceived Penalty Rates (Winsorized)") xtitle("Perceived Penalty Rate (percent)") saving(HistogramwinsorizedP, replace)
hist wP1, fraction bin(100) title("Distribution of Perceived Penalty Rates (Winsorized)") xtitle("Perceived Penalty Rate (percent)") saving(HistogramwinsorizedP1, replace)
hist wP2, fraction bin(100) title("Distribution of Perceived Penalty Rates (Winsorized)") xtitle("Perceived Penalty Rate (percent)") saving(HistogramwinsorizedP2, replace)
hist wP3, fraction bin(100) title("Distribution of Perceived Penalty Rates (Winsorized)") xtitle("Perceived Penalty Rate (percent)") saving(HistogramwinsorizedP3, replace)


hist T, fraction bin(25) title("Distribution of Perceived Tax Rates") xtitle("Perceived Tax Rate (percent)") saving(HistogramT, replace)

histbox A, bin(25) title("Distribution of Perceived Audit Rates") xtitle("Perceived Audit Rate (percent)") saving(HistBoxA, replace)
histbox P, bin(100) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") saving(HistBoxP, replace)
histbox T, bin(25) title("Distribution of Perceived Tax Rates") xtitle("Perceived Tax Rate (percent)") saving(HistBoxT, replace)*/

*********** Generating variables for perception biases for A, P and T **********
gen diffA1 = A - 0.7
gen diffA2 = A - 0.878
gen diffP1 = P - 75
gen diffP2 = P - 40
gen diffP3 = P - 20
gen diffwP1 = wP - 75
gen diffwP2 = wP - 40
gen diffwP3 = wP - 20
gen diffT1 = T - estT1
gen diffT2 = T - estT2
gen diffT3 = T - estT3
gen diffMT1 = T - MT1
gen diffMT2 = T - MT2
gen diffMT3 = T - MT3

*generating multinomial variable for P: 1. underestimates P; 2. estimates P reasonably well; 3. overestimates P
gen estimationP1 = 1 if diffP1 < -5 // for P = 75%
replace estimationP1 = 2 if diffP1 >= -5 & diffP1 <= 5
replace estimationP1 = 3 if diffP1 > 5 & diffP1 != .

gen estimationP2 = 1 if diffP2 < -5 // for P = 40%
replace estimationP2 = 2 if diffP2 >= -5 & diffP2 <= 5
replace estimationP2 = 3 if diffP2 > 5 & diffP2 != .

gen estimationP = 1 if diffP3 < -5 // for P = 20%
replace estimationP = 2 if diffP3 >= -5 & diffP3 <= 5
replace estimationP = 3 if diffP3 > 5 & diffP3 != .

label define multinomialP 1 "understimates the penalty rate" 2 "estimates the penalty rate reasonably well" 3 "overestimates the penalty rate"
label values estimationP multinomialP

*generating binary variable for P: = 1 if estimates P reasonably well; 0 otherwise
gen estP = 0 
replace estP = 1 if diffP3 >= -5 & diffP3 <= 5
replace estP = . if diffP3 == .

*generating binary variable for P: = 1 if P = 20; 0 otherwise
gen binaryP20 = 0
replace binaryP20 = 1 if P == 20
replace binaryP20 = . if P == .

gen multiP20 = .
replace multiP20 = 1 if P < 20
replace multiP20 = 2 if P == 20
replace multiP20 = 3 if P > 20 & P != .

label values multiP20 multinomialP

label define binaryP 1 "estimates P reasonably well" 0 "either overestimates or underestimates P"
label values estP binaryP
label values binaryP20 binaryP

gen underP = .
replace underP = 1 if P < 15
replace underP = 0 if P >= 15 & P != .

gen underP2 = .
replace underP2 = 1 if P < 15
replace underP2 = 0 if P >= 15 & P <= 25

gen overP = .
replace overP = 1 if P > 25 & P != .
replace overP = 0 if P <= 25

gen overP2 = .
replace overP2 = 1 if P > 25 & P != .
replace overP2 = 0 if P >= 15 & P <= 25

*************** Histograms for perception biases for A, P and T ****************
/*hist diffA1, fraction bin(25) title("Perception Gap for Audit Rate") xtitle("Differences Between Actual and Perceived Audit Rates (percentage points)") saving(HistogramA1, replace)
hist diffA2, fraction bin(25) title("Perception Gap for Audit Rate") xtitle("Differences Between Actual and Perceived Audit Rates (percentage points)") saving(HistogramA2, replace)
hist diffP1, fraction bin(100) title("Perception Gap for the Penalty Rate (75%)") xtitle("Differences Between Actual (75%) and Perceived Penalty Rates (percentage points)") saving(HistogramP1, replace)
hist diffP2, fraction bin(100) title("Perception Gap for the Penalty Rate (40%)") xtitle("Differences Between Actual (40%) and Perceived Penalty Rates (percentage points)") saving(HistogramP2, replace)
hist diffP3, fraction bin(100) title("Perception Gap for the Penalty Rate (20%)") xtitle("Differences Between Actual (20%) and Perceived Penalty Rates (percentage points)") saving(HistogramP3, replace)
hist diffT1, fraction bin(45) title("Perception Gap for Effective Tax Rate") xtitle("Estimated Actual Rate - Perceived Tax Rate (percentage points)") saving(HistogramT1, replace)
hist diffT2, fraction bin(45) title("Perception Gap for Effective Tax Rate") xtitle("Estimated Actual Rate - Perceived Tax Rate (percentage points)") saving(HistogramT2, replace)
hist diffT3, fraction bin(45) title("Perception Gap for Effective Tax Rate") xtitle("Estimated Actual Rate - Perceived Tax Rate (percentage points)") saving(HistogramT3, replace)
*/
su diffT1, detail
su diffT2, detail
su diffT3, detail

//graph combine HistogramP1.gph HistogramP2.gph HistogramP3.gph, saving("Perception Gaps for the Penalty Rate", replace)

**************************** t-tests for A, P and T ****************************
svyset [pw=weight]
*calculating weighted proportions for the responses for A, P and T
svy: tab A
svy: tab P
svy: tab T

svy: mean P
svy: mean wP
svy: mean sqrtP
svy: mean lnP
svy: mean A
svy: mean diffT1
svy: mean diffT2
svy: mean diffT3


*Estimating skewness and kurtosis of the penalty rate variables.
su sqrtP, detail //This transformation reduced substantially skewness and kurtosis, but they are still large (greater than 3).
su lnP, detail
su P, detail 

/*gen A_without_magnifier = real(perceivedauditrate)
svy: mean A_without_magnifier*/

svy: reg diffA1 //calculates t-test for H0: A == 0.7
svy: reg diffA2 //calculates t-test for H0: A == 0.878

svy: reg diffP1 //calculates t-test for H0: P == 75
svy: reg diffP2 //calculates t-test for H0: P == 40
svy: reg diffP3 //calculates t-test for H0: P == 20

svy: reg diffT1 //calculates t-test for the differences between estimated actual and perceived tax rates
svy: reg diffT2
svy: reg diffT3

svy: reg diffMT1 //calculates t-test for the differences between estimated actual marginal and perceived tax rates
svy: reg diffMT2
svy: reg diffMT3

*Non-parametric one-sample sign test for P
gen S1 = .
replace S1 = 0 if P > 75 & P != .
replace S1 = 1 if P < 75 
replace S1 = . if P == 75
bitest S1 == 0.5 //H0:P >= 75; H1:P < 75 (also for two-tailed test: H0:P = 75; H1:P != 75)
bitest S1 == 0.5 [fweight = int_weights]
bitest S1 == 0.5 [fweight = int_weights10]
gen P75 = 75
signtest P = P75

gen S2 = .
replace S2 = 0 if P > 40 & P != .
replace S2 = 1 if P < 40 
bitest S2 == 0.5 //H0:P >= 40; H1:P < 40 (also for two-tailed test: H0:P = 40; H1:P != 40)
bitest S2 == 0.5 [fweight = int_weights]
bitest S2 == 0.5 [fweight = int_weights10]
gen P40 = 40
signtest P = P40

gen S3 = .
replace S3 = 0 if P > 20 & P != .
replace S3 = 1 if P < 20 
bitest S3 == 0.5 //H0:P >= 20; H1:P < 20 (also for two-tailed test: H0:P = 20; H1:P != 20)
bitest S3 == 0.5 [fweight = int_weights]
bitest S3 == 0.5 [fweight = int_weights10]
gen P20 = 20
signtest P = P20

*One sample sign test for P based on weight variable
su weight if P != .
scalar Pop_Size = round(r(sum))

su weight if P < 75
scalar Below75 = round(r(sum))
su weight if P < 40
scalar Below40 = round(r(sum))
su weight if P < 20
scalar Below20 = round(r(sum))

su weight if P == 75
scalar Equal75 = round(r(sum))
su weight if P == 40
scalar Equal40 = round(r(sum))
su weight if P == 20
scalar Equal20 = round(r(sum))

su weight if P > 75 & P != .
scalar Above75 = round(r(sum))
su weight if P > 40 & P != .
scalar Above40 = round(r(sum))
su weight if P > 20 & P != .
scalar Above20 = round(r(sum))

di "Below75= " Below75 "; " "Equal75= " Equal75 "; " "Above75= " Above75
di "Below40= " Below40 "; " "Equal40= " Equal40 "; " "Above40= " Above40
di "Below20= " Below20 "; " "Equal20= " Equal20 "; " "Above20= " Above20

bitesti (Below75+Above75) Below75 0.5 //H0:P >= 75; H1:P < 75 (also for two-tailed test: H0:P = 75; H1:P != 75)
bitesti (Below40+Above40) Below40 0.5 //H0:P >= 40; H1:P < 40 (also for two-tailed test: H0:P = 40; H1:P != 40)
bitesti (Below20+Above20) Below20 0.5 //H0:P >= 20; H1:P < 20 (also for two-tailed test: H0:P = 20; H1:P != 20)



*t-test for P with the transformed variable to reduce skewness (sqrtP)
svy: reg sqrtP
scalar t1 = (_b[_cons] - sqrt(75))/_se[_cons] //calculates t-test for H0: sqrtP == sqrt(75)
di t1
scalar t2 = (_b[_cons] - sqrt(40))/_se[_cons] //calculates t-test for H0: sqrtP == sqrt(40)
di t2
scalar t3 = (_b[_cons] - sqrt(20))/_se[_cons] //calculates t-test for H0: sqrtP == sqrt(20)
di t3

*t-test for P with the transformed variable to reduce skewness (lnP)
svy: reg lnP
scalar t4 = (_b[_cons] - ln(75))/_se[_cons] //calculates t-test for H0: lnP == ln(75)
di t4
scalar t5 = (_b[_cons] - ln(40))/_se[_cons] //calculates t-test for H0: lnP == ln(40)
di t5
scalar t6 = (_b[_cons] - ln(20))/_se[_cons] //calculates t-test for H0: lnP == ln(20)
di t6

ameans P //calculates geometric mean for P (unweighted).

svy: reg diffwP1 //calculates t-test for H0: wP == 75
svy: reg diffwP2 //calculates t-test for H0: wP == 40
svy: reg diffwP3 //calculates t-test for H0: wP == 20


*************************** Correlations between estT, MT and T **************************
*Estimating Pearson's correlation coefficients with the survey weights
cor estT1 estT2 estT3 MT1 MT2 MT3 T [aw= weight] //Calculating coefficients (Pearson)

* Estimating p-values for the Pearson's correlation coefficients with the survey weights (Pick the biggest p-value as a conservative estimate.)
foreach var of varlist estT1-MT3 {
svy: reg T `var'
scalar d`var' = sqrt(e(r2))
di "r = " d`var'
svy: reg `var' T
scalar d`var'a = sqrt(e(r2))
di "r = "d`var'a
}

spearman estT1 estT2 estT3 MT1 MT2 MT3 T, stats (rho p)
ktau estT1 estT2 estT3 MT1 MT2 MT3 T, stats(taua taub p)

**************************** Data cleaning for the Regression Analyses ****************************
*Transforming rate variables (like A,P and T) into fraction for fracreg models
gen double A1 = A/100
gen double T1 = T/100
gen double P1 = P/100
gen double estT1frac = estT1/100
gen double estT2frac = estT2/100
gen double estT3frac = estT3/100
gen double pcaught = perceivedcaught/100
gen double MTR1 = MT1/100
gen double MTR2 = MT2/100
gen double MTR3 = MT3/100
gen double  prob_deduction= refunddebt/100
gen double absdiffT1frac = abs(T1 - estT1frac)


replace perceivedevasionratepopulation = "0" if perceivedevasionratepopulation == "00-"
gen double perceivedevasionratepop = real(perceivedevasionratepopulation)/100 //converting perceivedevasionratepopulation variable into a numeric variable

*Generating binary variable for Age > 65: = 1 if respondent is over 65, 0 otherwise
gen over65 = 0
replace over65 = 1 if calcage > 65  

*Generating binary variable for gender: = 1 if male, 0 otherwise
gen male = 1
replace male = 0 if gender == 2

*Generating binary variable for married: = 1 if married or living with a partner , 0 otherwise
gen married = 0
replace married = 1 if currentlivingsituation == 1

*Generating binary variable for foreignborn: = 1 if foreign born, 0 otherwise
gen foreignborn = .
replace foreignborn = 1 if borninus == 2
replace foreignborn = 0 if borninus == 1

*Generating binary variables for race (White/Caucasian is a reference group)
gen BlackAA = 0 //Black or African American
replace BlackAA = 1 if ethnicity == 2

gen Native = 0 // Native American 
replace Native = 1 if ethnicity == 3

gen Asian = 0 // Asian or Pacific Islander
replace Asian = 1 if ethnicity == 4

gen Otherrace = 0 // Other race
replace Otherrace = 1 if ethnicity == 5

*Generating binary variable for education: = 1 if has bachelor degree or above, 0 otherwise.
gen education = 0
replace education = 1 if highesteducation >= 13

*Generating binary variables for family income
gen incless_than_5000 = 0
replace incless_than_5000 = 1 if hhincome1 == 1
replace incless_than_5000 = . if hhincome1 == .

gen inc5000_7499 = 0
replace inc5000_7499 = 1 if hhincome1 == 2
replace inc5000_7499 = . if hhincome1 == .

gen inc7500_9999 = 0
replace inc7500_9999 = 1 if hhincome1 == 3
replace inc7500_9999 = . if hhincome1 == .

gen inc10000_12499 = 0
replace inc10000_12499 = 1 if hhincome1 == 4
replace inc10000_12499 = . if hhincome1 == .

gen inc12500_14999 = 0
replace inc12500_14999 = 1 if hhincome1 == 5
replace inc12500_14999 = . if hhincome1 == .

gen inc15000_19999 = 0
replace inc15000_19999 = 1 if hhincome1 == 6
replace inc15000_19999 = . if hhincome1 == .

gen inc20000_24999 = 0
replace inc20000_24999 = 1 if hhincome1 == 7
replace inc20000_24999 = . if hhincome1 == .

gen inc25000_29999 = 0
replace inc25000_29999 = 1 if hhincome1 == 8
replace inc25000_29999 = . if hhincome1 == .

gen inc30000_34999 = 0
replace inc30000_34999 = 1 if hhincome1 == 9
replace inc30000_34999 = . if hhincome1 == .

gen inc35000_39999 = 0
replace inc35000_39999 = 1 if hhincome1 == 10
replace inc35000_39999 = . if hhincome1 == .

gen inc40000_49999 = 0
replace inc40000_49999 = 1 if hhincome1 == 11
replace inc40000_49999 = . if hhincome1 == .

gen inc50000_59999 = 0
replace inc50000_59999 = 1 if hhincome1 == 12
replace inc50000_59999 = . if hhincome1 == .

gen inc60000_74999 = 0
replace inc60000_74999 = 1 if hhincome1 == 13
replace inc60000_74999 = . if hhincome1 == .

gen inc75000_99999 = 0
replace inc75000_99999 = 1 if hhincome1 == 14
replace inc75000_99999 = . if hhincome1 == .

gen inc100000_124999 = 0
replace inc100000_124999 = 1 if hhincome1 == 15
replace inc100000_124999 = . if hhincome1 == .

gen inc125000_199999 = 0
replace inc125000_199999 = 1 if hhincome1 == 16
replace inc125000_199999 = . if hhincome1 == .

gen incover200k = 0
replace incover200k = 1 if hhincome1 == 17
replace incover200k = . if hhincome1 == .

*family income based on hhincome2
gen incless_than_5000a = 0
replace incless_than_5000a = 1 if hhincome2 == 1
replace incless_than_5000a = . if hhincome2 == .

gen inc5000_7499a = 0
replace inc5000_7499a = 1 if hhincome2 == 2
replace inc5000_7499a = . if hhincome2 == .

gen inc7500_9999a = 0
replace inc7500_9999a = 1 if hhincome2 == 3
replace inc7500_9999a = . if hhincome2 == .

gen inc10000_12499a = 0
replace inc10000_12499a = 1 if hhincome2 == 4
replace inc10000_12499a = . if hhincome2 == .

gen inc12500_14999a = 0
replace inc12500_14999a = 1 if hhincome2 == 5
replace inc12500_14999a = . if hhincome2 == .

gen inc15000_19999a = 0
replace inc15000_19999a = 1 if hhincome2 == 6
replace inc15000_19999a = . if hhincome2 == .

gen inc20000_24999a = 0
replace inc20000_24999a = 1 if hhincome2 == 7
replace inc20000_24999a = . if hhincome2 == .

gen inc25000_29999a = 0
replace inc25000_29999a = 1 if hhincome2 == 8
replace inc25000_29999a = . if hhincome2 == .

gen inc30000_34999a = 0
replace inc30000_34999a = 1 if hhincome2 == 9
replace inc30000_34999a = . if hhincome2 == .

gen inc35000_39999a = 0
replace inc35000_39999a = 1 if hhincome2 == 10
replace inc35000_39999a = . if hhincome2 == .

gen inc40000_49999a = 0
replace inc40000_49999a = 1 if hhincome2 == 11
replace inc40000_49999a = . if hhincome2 == .

gen inc50000_59999a = 0
replace inc50000_59999a = 1 if hhincome2 == 12
replace inc50000_59999a = . if hhincome2 == .

gen inc60000_74999a = 0
replace inc60000_74999a = 1 if hhincome2 == 13
replace inc60000_74999a = . if hhincome2 == .

gen inc75000_99999a = 0
replace inc75000_99999a = 1 if hhincome2 == 14
replace inc75000_99999a = . if hhincome2 == .

gen inc100000_124999a = 0
replace inc100000_124999a = 1 if hhincome2 == 15
replace inc100000_124999a = . if hhincome2 == .

gen inc125000_199999a = 0
replace inc125000_199999a = 1 if hhincome2 == 16
replace inc125000_199999a = . if hhincome2 == .

gen incover200ka = 0
replace incover200ka = 1 if hhincome2 == 17
replace incover200ka = . if hhincome2 == .

*family income based on hhincome3
gen incless_than_5000b = 0
replace incless_than_5000b = 1 if hhincome3 == 1
replace incless_than_5000b = . if hhincome3 == .

gen inc5000_7499b = 0
replace inc5000_7499b = 1 if hhincome3 == 2
replace inc5000_7499b = . if hhincome3 == .

gen inc7500_9999b = 0
replace inc7500_9999b = 1 if hhincome3 == 3
replace inc7500_9999b = . if hhincome3 == .

gen inc10000_12499b = 0
replace inc10000_12499b = 1 if hhincome3 == 4
replace inc10000_12499b = . if hhincome3 == .

gen inc12500_14999b = 0
replace inc12500_14999b = 1 if hhincome3 == 5
replace inc12500_14999b = . if hhincome3 == .

gen inc15000_19999b = 0
replace inc15000_19999b = 1 if hhincome3 == 6
replace inc15000_19999b = . if hhincome3 == .

gen inc20000_24999b = 0
replace inc20000_24999b = 1 if hhincome3 == 7
replace inc20000_24999b = . if hhincome3 == .

gen inc25000_29999b = 0
replace inc25000_29999b = 1 if hhincome3 == 8
replace inc25000_29999b = . if hhincome3 == .

gen inc30000_34999b = 0
replace inc30000_34999b = 1 if hhincome3 == 9
replace inc30000_34999b = . if hhincome3 == .

gen inc35000_39999b = 0
replace inc35000_39999b = 1 if hhincome3 == 10
replace inc35000_39999b = . if hhincome3 == .

gen inc40000_49999b = 0
replace inc40000_49999b = 1 if hhincome3 == 11
replace inc40000_49999b = . if hhincome3 == .

gen inc50000_59999b = 0
replace inc50000_59999b = 1 if hhincome3 == 12
replace inc50000_59999b = . if hhincome3 == .

gen inc60000_74999b = 0
replace inc60000_74999b = 1 if hhincome3 == 13
replace inc60000_74999b = . if hhincome3 == .

gen inc75000_99999b = 0
replace inc75000_99999b = 1 if hhincome3 == 14
replace inc75000_99999b = . if hhincome3 == .

gen inc100000_124999b = 0
replace inc100000_124999b = 1 if hhincome3 == 15
replace inc100000_124999b = . if hhincome3 == .

gen inc125000_199999b = 0
replace inc125000_199999b = 1 if hhincome3 == 16
replace inc125000_199999b = . if hhincome3 == .

gen incover200kb = 0
replace incover200kb = 1 if hhincome3 == 17
replace incover200kb = . if hhincome3 == .

*Generating binary variable for hispaniclatino = 1 if hispanic or latino; 0 otherwise
replace hispaniclatino = 0 if hispaniclatino == 2

*Generating binary variable for self-employed: =1 if self-employed, 0 otherwise
gen selfemployed1 = 1 if selfemployed == 2
replace selfemployed1 = 0 if selfemployed == 1 | selfemployed == 3
gen selfemployed2 = 0 //This variable also includes missing values
replace selfemployed2 = 1 if selfemployed == 2

*Generating binary variable for workforsomeoneelse: = 1 if works for someone else, 0 otherwise
gen workforsomeoneelse = 0
replace workforsomeoneelse = 1 if selfemployed == 1

*Generating binary variable for notworthpayingtaxes = 1 if respondent thinks that public services DOESN'T worth federal taxes he/she pays, 0 otherwise
gen notworthpayingtaxes = 0
replace notworthpayingtaxes = 1 if servicestaxes == 1 | servicestaxes == 2
replace notworthpayingtaxes = . if servicestaxes == .

*Generating binary variable for worthpayingtaxes = 1 if respondent thinks that public services worth federal taxes he/she pays, 0 otherwise
gen worthpayingtaxes = 0
replace worthpayingtaxes = 1 if servicestaxes == 4 | servicestaxes == 5
replace worthpayingtaxes = . if servicestaxes == .

*Generating binary variable for fr11never = 1 if respondent stated that it is never ok to regularly listen to public radio without ever contributing, 0 otherwise
gen fr11never = 0
replace fr11never = 1 if fr11 == 3
replace fr11never = . if fr11 == .

*Generating binary variable for fr12never = 1 if respondent stated that it is never ok to illegally copy, download, or stream movies; 0 otherwise
gen fr12never = 0
replace fr12never = 1 if fr12 == 3
replace fr12never = . if fr12 == .

*Generating binary variable for fr13never = 1 if respondent stated that it is never ok to have a dog but not getting it spayed or neutered; 0 otherwise
gen fr13never = 0
replace fr13never = 1 if fr13 == 3
replace fr13never = . if fr13 == .

*Generating binary variable for fr14never = 1 if respondent stated that it is never ok to avoid getting the flu vaccine; 0 otherwise
gen fr14never = 0
replace fr14never = 1 if fr14 == 3
replace fr14never = . if fr14 == .

*Generating binary variable for fr15never = 1 if respondent stated that it is never ok to avoid paying all of the income tax that you owe; 0 otherwise
gen fr15never = 0
replace fr15never = 1 if fr15 == 3
replace fr15never = . if fr15 == .

*Generating binary variable for fr11ok = 1 if respondent stated that it is always or sometimes ok to regularly listen to public radio without ever contributing, 0 otherwise
gen fr11ok = 0
replace fr11ok = 1 if fr11 <= 2

*Generating binary variable for fr12ok = 1 if respondent stated that it is always or sometimes ok to illegally copy, download, or stream movies; 0 otherwise
gen fr12ok = 0
replace fr12ok = 1 if fr12 <= 2

*Generating binary variable for fr13ok = 1 if respondent stated that it is always or sometimes ok to have a dog but not getting it spayed or neutered; 0 otherwise
gen fr13ok = 0
replace fr13ok = 1 if fr13 <= 2

*Generating binary variable for fr14ok = 1 if respondent stated that it is always or sometimes ok to avoid getting the flu vaccine; 0 otherwise
gen fr14ok = 0
replace fr14ok = 1 if fr14 <= 2

*Generating binary variable for fr15ok = 1 if respondent stated that it is always or sometimes ok to avoid paying all of the income tax that you owe; 0 otherwise
gen fr15ok = 0
replace fr15ok = 1 if fr15 <= 2

*Generating an aggregate variable for fr11-fr15 variables
gen fr_never = fr11never + fr12never + fr13never + fr14never + fr15never
egen fr_never2 = rowtotal(fr11never fr12never fr13never fr14never fr15never), missing
gen fr_ok = fr11ok + fr12ok + fr13ok + fr14ok + fr15ok

*Generating an aggregate variable for fr21-fr25 questions
egen fr2 = rowmean(fr21-fr25)

*Generating binary variables from the categories for the "actor" variable
gen actor_more = 0 
replace actor_more = 1 if actor <= 2 //much or somewhat more likely to fully report = 1, and = 0 if otherwise

gen actor_less = 0 
replace actor_less = 1 if actor == 4 | actor == 5 //somewhat or much less likely to fully report = 1, and = 0 if otherwise


*Generating binary variable for preptaxesself: = 1 if respondent indicated that he/she prepares tax himself/herself, 0 otherwise
gen preptaxesself = 0
replace preptaxesself = 1 if preptaxes == 1 | preptaxes == 2
replace preptaxesself = . if preptaxes == .

*Generating binary variable for everfiledtaxes: = 1 if respondent DID NOT file taxes or doesn't know or can't remember, 0 otherwise
gen haventfiledtaxes = 0
replace haventfiledtaxes = 1 if everfiledtaxes == 2 | everfiledtaxes == 3
replace haventfiledtaxes = . if everfiledtaxes == .

*Generating everaudited1 which = 1 if a respondent reported that he/she had ever been audited by the IRS, and = 0 if otherwise
gen everaudited1 = 0
replace everaudited1 = 1 if everaudited == 1 //with no missing values

gen everaudited2 = 0
replace everaudited2 = 1 if everaudited == 1 
replace everaudited2 = . if everaudited == . //with missing values

*Generating hheveruadited which =1 if either respondent or his/her spouse had ever been audited by the IRS, and = 0 if otherwise
gen hheveraudited = 0
replace hheveraudited = 1 if everaudited == 1 | spouseaudit == 2

*Generating the total number of alters
 *1) Generating a binary variable for alters_n_ variables (= 1 if alters_n_ is not empty, = 0 otherwise)
 foreach num of numlist 1/10 {
 gen alters`num' = 1 if alters_`num'_ != ""
 replace alters`num' = 0 if alters`num' == . 
 }
 *
*2) Generating a variable for total number of alters mentioned by the respondent (n_alters)
egen n_alters = rowtotal(alters1-alters10), missing

 *?????drop if prim_key == "10047542:1"  //dropping observation for which the respondent indicated numbers instead of initials in the alter matrix.

*Generating binary variable for the self-employment of alters
 foreach num of numlist 1/10 {
gen taxselfemployed`num' = 0
replace taxselfemployed`num' = 1 if taxselfemployed_`num'_ == 1 
 }
 *
egen n_altersselfemployed = rowtotal(taxselfemployed1-taxselfemployed10), missing

*Generating a variable for the proportion of alters who are self-employed.
gen alterselfemployed = n_altersselfemployed/n_alters

*Generating binary variable for alters who talked about taxes with a respondent
 foreach num of numlist 1/10 {
gen altertalktax`num' = 0
replace altertalktax`num' = 1 if altertalktax_`num'_ == 1 
 }
 *
egen n_altertalktax = rowtotal(altertalktax1-altertalktax10) // total number of alters with whom a respondent talked about taxes

*Generating a variable for the proportion of alters with whom a respondent talked about taxes
gen prop_alters_tTaxes = n_altertalktax/n_alters


*Generating binary variable for alters who respondent thinks have been audited
 foreach num of numlist 1/10 {
tab taxaudit_`num'_, m
 }
 *
 foreach num of numlist 1/10 {
gen taxaudit`num' = 0
replace taxaudit`num' = 1 if taxaudit_`num'_ == 1 | taxaudit_`num'_ == 2
 }
 *
egen n_altersaudited = rowtotal(taxaudit1 - taxaudit10) // total number of alters who have been "audited"
 
*Generating a variable for the proportion of alters who respondent thinks have been audited.
gen prop_altersaudited = n_altersaudited/n_alters

*Checking legitimate missing values in taxesimportant_c and taxesimportant_d
egen total = rowtotal(taxesimportant_a - taxesimportant_d), m
list  taxesimportant_a taxesimportant_b taxesimportant_c taxesimportant_d total if total > 100 & total != .
replace taxesimportant_a = taxesimportant_a/total*100 if total > 100 & total != . //for few respondents the total was over 100, these commands normalize the responses to 100.
replace taxesimportant_b = taxesimportant_b/total*100 if total > 100 & total != .
replace taxesimportant_c = taxesimportant_c/total*100 if total > 100 & total != .
replace taxesimportant_d = taxesimportant_d/total*100 if total > 100 & total != .
replace taxesimportant_a = 0 if taxesimportant_a == . & total == 100 // replacing missing values with 0 if total is 100
replace taxesimportant_b = 0 if taxesimportant_b == . & total == 100
replace taxesimportant_c = 0 if taxesimportant_c == . & total == 100
replace taxesimportant_d = 0 if taxesimportant_d == . & total == 100

replace taxesimportant_d = 0 if total != . & taxesimportant_d == . & taxesfairness_a != . //replacing missing value if total is not missing and next questions is also not missing.
replace taxesimportant_d = 0 if total != . & taxesimportant_d == . & riskauditspenalties_a != .
* The assumption for the command above is that respondents did not answered to taxesimportant_d, because they do not think it is important.

*Generate an interaction term for hispaniclatino and selfemployed
gen hispseflemployed = hispaniclatino*selfemployed2

**************************** regression models for A ****************************

global xlist1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never-fr15never worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist1a calcage BlackAA - Otherrace hispaniclatino male married education foreignborn MTR1 selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed hheveraudited haventfiledtaxes preptaxesself prob_deduction actor_more fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist1b calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr_never fr21-fr25 worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist1c calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hispseflemployed hheveraudited haventfiledtaxes preptaxesself actor_less fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist1d calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_more fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist2 calcage BlackAA - Otherrace hispaniclatino male married  education prob_deduction foreignborn estT1frac prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never-fr15never worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist1c P1 T1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d

*For slides
global xlist1s calcage BlackAA - Otherrace hispaniclatino male married education foreignborn MTR1 selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed hheveraudited haventfiledtaxes preptaxesself prob_deduction actor_more fr2 worthpayingtaxes taxesimportant_d
reg A1 $xlist1s [pw = weight]


*correlation with xlist1a variables
cor A1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d [aw=weight]
cor A1 calcage BlackAA - Otherrace hispaniclatino male married education foreignborn MTR1 selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed hheveraudited haventfiledtaxes preptaxesself prob_deduction actor_more fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d [aw=weight]


/*Other correlations with A
cor A1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction T1 P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never-fr15never worthpayingtaxes taxesimportant_a - taxesimportant_d [aw=weight]
cor A1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr_never fr21-fr25 worthpayingtaxes taxesimportant_c taxesimportant_d [aw=weight]
cor A1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction P1 foreignborn estT1frac - estT3frac MTR1 - MTR3 inc5000_7499 - incover200k inc5000_7499a - incover200ka inc5000_7499b - incover200kb pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed1 selfemployed2 workforsomeoneelse everaudited1 everaudited2 hheveraudited haventfiledtaxes preptaxesself actor_less actor_more fr11ok - fr15ok fr11never - fr15never notworthpayingtaxes worthpayingtaxes taxesimportant_c  taxesimportant_d [aw=weight]
spearman A1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction P1 foreignborn estT1frac - estT3frac MTR1 - MTR3 inc5000_7499 - incover200k inc5000_7499a - incover200ka inc5000_7499b - incover200kb pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed1 selfemployed2 workforsomeoneelse everaudited1 everaudited2 hheveraudited haventfiledtaxes preptaxesself actor_less actor_more fr11ok - fr15ok fr11never - fr15never notworthpayingtaxes worthpayingtaxes taxesimportant_c taxesimportant_d
ktau A1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction P1 foreignborn estT1frac - estT3frac MTR1 - MTR3 inc5000_7499 - incover200k inc5000_7499a - incover200ka inc5000_7499b - incover200kb pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed1 selfemployed2 workforsomeoneelse everaudited1 everaudited2 hheveraudited haventfiledtaxes preptaxesself actor_less actor_more fr11ok - fr15ok fr11never - fr15never notworthpayingtaxes worthpayingtaxes taxesimportant_c taxesimportant_d
*/

*Box-Cox test to determine relationship between X*beta and E(y|X)
boxcox A1 $xlist1a if A1 >0
boxcox A1 $xlist2 if A1 >0
*The results show that the relationship is not linear. Theta is 0.382 which is close to square root functional form. So cloglog and loglog might be better fits.

*GLM Family Test
svy: glm A1 $xlist1a, family(gamma) link(log)
predict double xbetahat, xb
gen double rawresid = A1 - exp(xbetahat)
gen double rawvar = rawresid^2
gen double xbetahat2 = xbetahat^2
svy: glm rawvar xbetahat, family(gamma) link(log) nolog //family test
test xbetahat - 2 = 0 //Gamma family
svy: glm rawvar xbetahat xbetahat2, link(log) family(gamma) nolog //cheking fit for family test using Pregibon's Link Test
*Results indicate something between gamma and poisson distribution

gen sqrtA1 = sqrt(A1)


*main LPM models
svy: reg A1 $xlist1a
linktest
ovtest
reg A1 $xlist1a [pw =weight]
estat ic

reg A1 $xlist1b [pw =weight]
estat ic

svy: reg A1 $xlist2
linktest
ovtest
reg A1 $xlist2 [pw =weight]
estat ic

reg sqrtA1 $xlist1 [pw =weight]
estat ic

reg sqrtA1 $xlist1a [pw =weight]
estat ic

reg sqrtA1 $xlist1b [pw =weight]
estat ic

reg sqrtA1 $xlist2 [pw =weight]
estat ic

*SqrtA1 models
glm A1 $xlist1a [pw=weight], family(gamma) link(pow 0.5)
svy: glm A1 $xlist1a, family(gamma) link(pow 0.5)
linktest

glm A1 $xlist1a [pw=weight], family(gamma) link(pow 0.5)
svy: glm A1 $xlist1a, family(gamma) link(pow 0.5)
linktest


*main fractional response models
*main probit
svy: glm A1 $xlist1a, link (p) family(binomial)
linktest

glm A1 $xlist1a [pw = weight], link (p) family(binomial)
estat ic

svy: glm A1 $xlist2, link (p) family(binomial)
fracreg probit A1 $xlist1a [pw = weight], vce(robust) //yields the same results as svy:glm in this case
estat ic
*main probit with heterescedasticity
fracreg probit A1 $xlist1 [pw = weight], vce(robust) het($xlist1)
svy: fracreg probit A1 $xlist1, het($xlist1)
fracreg probit A1 $xlist2 [pw = weight], vce(robust) het($xlist2)
estat ic

*main logit
svy: glm A1 $xlist1, link (l) family(binomial)
linktest

svy: glm A1 $xlist1a, link (l) family(binomial)
fracreg logit A1 $xlist1a [pw = weight], vce(robust) //yields the same results as svy:glm in this case
estat ic
glm A1 $xlist1a [pw= weight], link (l) family(binomial)
estat ic
glm A1 $xlist1a, link (l) family(binomial)


fracreg logit A1 $xlist2 [pw = weight], vce(robust) //yields the same results as svy:glm in this case
estat ic

*main loglog
svy: glm A1 $xlist1, link (loglog) family(binomial)
svy: glm A1 $xlist1a, link (loglog) family(binomial)
linktest

glm A1 $xlist1a [pw=weight], link (loglog) family(binomial) //yields the same result as svy, but allows to estimate AIC and BIC
estat ic
glm A1 $xlist2 [pw=weight], link (loglog) family(binomial) //yields the same result as svy, but allows to estimate AIC and BIC
estat ic

*main cloglog
svy: glm A1 $xlist1a, link (cloglog) family(binomial)
svy: glm A1 $xlist2, link (cloglog) family(binomial)
linktest

glm A1 $xlist1a [pw=weight], link (cloglog) family(binomial) //yields the same result as svy, but allows to estimate AIC and BIC
estat ic

glm A1 $xlist2 [pw=weight], link (cloglog) family(binomial) //yields the same result as svy, but allows to estimate AIC and BIC
estat ic

*main family gamma and link loglog
glm A1 $xlist1a [pw=weight], family(gamma) link(loglog)
estat ic
linktest

glm A1 $xlist2 [pw=weight], family(gamma) link(loglog)
estat ic
linktest

*main family gamma and link cloglog
glm A1 $xlist1a [pw=weight], family(gamma) link(cloglog)
estat ic
linktest

glm A1 $xlist2 [pw=weight], family(gamma) link(cloglog)
estat ic
linktest

/*others
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn inc5000_7499 - incover200k pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
di " VIF = " 1/(1-e(r2))
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn inc5000_7499 - incover200k pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
di " VIF = " 1/(1-e(r2))
* income and related variables with age
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn inc5000_7499a - incover200ka pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn inc5000_7499a - incover200ka pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn inc5000_7499b - incover200kb pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn inc5000_7499b - incover200kb pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn estT1frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn estT1frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn estT2frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn estT2frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn estT3frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn estT3frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR2 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR2 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR3 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR3 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c

*age with selfemployed variables
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn inc5000_7499 - incover200k pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed1 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn inc5000_7499 - incover200k pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed1 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed workforsomeoneelse hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed workforsomeoneelse hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn inc5000_7499 - incover200k pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed workforsomeoneelse hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn inc5000_7499 - incover200k pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed workforsomeoneelse hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c

*notworth- vs worthpayingtaxes 
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never notworthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never notworthpayingtaxes taxesimportant_c
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes

*fr.ok vs fr.never
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11ok-fr15ok worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11ok-fr15ok worthpayingtaxes taxesimportant_c

*actor_less vs. actor_more
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_more fr11ok-fr15ok worthpayingtaxes taxesimportant_c
svy: reg A1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_more fr11ok-fr15ok worthpayingtaxes taxesimportant_c

*everaduited vs hheveraudited
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never-fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 everaudited1 haventfiledtaxes preptaxesself actor_less fr11never-fr15never worthpayingtaxes taxesimportant_c
svy: reg A1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction P1 foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 everaudited2 haventfiledtaxes preptaxesself actor_less fr11never-fr15never worthpayingtaxes taxesimportant_c

*other probit models
fracreg probit A1 $xlist1 
fracreg probit A1 $xlist1, het($xlist1)
fracreg probit A1 $xlist2 
fracreg probit A1 $xlist2, het($xlist2)

glm A1 $xlist1, vce(robust) link (p) family(binomial)
glm A1 $xlist2, vce(robust) link (p) family(binomial)

*other logit models
fracreg logit A1 $xlist1 [pw = weight]
fracreg logit A1 $xlist2
glm A1 $xlist1, vce(robust) link (l) family(binomial)
glm A1 $xlist2, vce(robust) link (l) family(binomial)*/

**************************** regression models for P ****************************
global xlist3 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never - fr15never worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist3a calcage BlackAA - Otherrace hispaniclatino male married education foreignborn MTR1 selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed hheveraudited haventfiledtaxes preptaxesself pcaught prob_deduction actor_more fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist3b calcage i.BlackAA i.Native i.Asian i.Otherrace i.hispaniclatino i.male i.married i.education i.foreignborn MTR1 i.selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed i.hheveraudited i.haventfiledtaxes i.preptaxesself pcaught prob_deduction i.actor_more fr_never fr2 i.worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist3c calcage i.BlackAA i.Native i.Asian i.Otherrace i.hispaniclatino i.male i.married i.education i.foreignborn MTR1 i.selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed i.hheveraudited i.haventfiledtaxes i.preptaxesself pcaught prob_deduction i.actor_more i.fr11never i.fr12never i.fr13never i.fr14never i.fr15never fr2 i.worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist3d calcage i.BlackAA i.Native i.Asian i.Otherrace i.foreignborn i.selfemployed2 alterselfemployed i.preptaxesself pcaught i.actor_more fr_never i.worthpayingtaxes taxesimportant_c taxesimportant_d


global xlist4 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn estT1frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never - fr15never worthpayingtaxes taxesimportant_c taxesimportant_d
*cor P1 A1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never - fr15never worthpayingtaxes taxesimportant_c taxesimportant_d [aw = weight]

*main correlation calculations
cor P1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d [aw = weight]
cor P1 calcage BlackAA - Otherrace hispaniclatino male married education foreignborn MTR1 selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed hheveraudited haventfiledtaxes preptaxesself pcaught prob_deduction actor_more fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d [aw = weight]


*Box-Cox test to determine relationship between X*beta and E(y|X)
boxcox P1 $xlist3a if P1 >0
boxcox P1 $xlist4 if P1 >0
*The results show that the relationship is log-linear. Theta is close to zero.

*GLM Family Test
svy: glm P1 $xlist3a, family(gamma) link(log)
predict xbetahatp, xb
gen rawresidp = P1 - exp(xbetahatp)
gen rawvarp = rawresidp^2
svy: glm rawvarp xbetahatp, family(gamma) link(log)
*Results indicate that the distribution is close to gamma distribution since the coefficient is close to 2.


*main linear models
gen lnP1 = ln(P1) //loosing some observations who indicated that P1 = 0 (about 8)

svy: reg P1 $xlist3a
linktest
ovtest

reg P1 $xlist3a [pw = weight]
estat ic

svy: reg P1 $xlist4
linktest
ovtest

reg P1 $xlist4 [pw = weight]
estat ic

*Log linear models
svy: reg lnP1 $xlist3a
linktest
ovtest

reg lnP1 $xlist3a [pw = weight]
estat ic

svy: reg lnP1 $xlist4
linktest
ovtest


*glm models
glm P1 $xlist3a [pw = weight], family(gamma) link(log)
linktest
estat ic

glm P1 $xlist4 [pw = weight], family(gamma) link(log)
linktest
estat ic

*multinomial logit model
svy: mlogit estimationP $xlist3a, baseoutcome(2)
svy: mlogit, rrr

svy: mlogit estimationP $xlist3d, baseoutcome(2)
svy: mlogit, rrr

svy: mlogit estimationP $xlist3b, baseoutcome(2)
svy: mlogit, rrr

margins, dydx(*) predict(outcome(2)) //average marginal effects
margins, dydx(*) predict(outcome(1)) //underestimating
margins, dydx(*) predict(outcome(3)) //overestimating

svy: mlogit multiP20 $xlist3b, baseoutcome (2)
margins, dydx(*) predict(outcome(2)) //average marginal effects
margins, dydx(*) predict(outcome(1)) //underestimating
margins, dydx(*) predict(outcome(3)) //overestimating

*simple logit model
svy: logit estP $xlist3b
margins, dydx(*)
svy: logit estP $xlist3c
margins, dydx(*)

svy: logit binaryP20 $xlist3b
margins, dydx(*)

svy: logit underP $xlist3b

/*others
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn inc5000_7499 - incover200k pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never-fr15never worthpayingtaxes taxesimportant_c
di " VIF = " 1/(1-e(r2))
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn inc5000_7499 - incover200k pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
di " VIF = " 1/(1-e(r2))
* income and related variables with age
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn inc5000_7499a - incover200ka pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn inc5000_7499a - incover200ka pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn inc5000_7499b - incover200kb pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn inc5000_7499b - incover200kb pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn estT1frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn estT1frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn estT2frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn estT2frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn estT3frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn estT3frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR2 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR2 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR3 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR3 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c

*age with selfemployed variables
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn inc5000_7499 - incover200k pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed1 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn inc5000_7499 - incover200k pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed1 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed workforsomeoneelse hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed workforsomeoneelse hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn inc5000_7499 - incover200k pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed workforsomeoneelse hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn inc5000_7499 - incover200k pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed workforsomeoneelse hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c

*notworth- vs worthpayingtaxes 
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never notworthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never notworthpayingtaxes taxesimportant_c
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never fr12never fr13never fr14never fr15never worthpayingtaxes

*fr.ok vs fr.never
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11ok-fr15ok worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11ok-fr15ok worthpayingtaxes taxesimportant_c

*actor_less vs. actor_more
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_more fr11ok-fr15ok worthpayingtaxes taxesimportant_c
svy: reg lnP1 over65 BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_more fr11ok-fr15ok worthpayingtaxes taxesimportant_c

*everaduited vs hheveraudited
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never-fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 everaudited1 haventfiledtaxes preptaxesself actor_less fr11never-fr15never worthpayingtaxes taxesimportant_c
svy: reg lnP1 calcage BlackAA - Otherrace hispaniclatino male married  prob_deduction education foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 everaudited2 haventfiledtaxes preptaxesself actor_less fr11never-fr15never worthpayingtaxes taxesimportant_c
*/

**************************** regression models for T ****************************
global xlist5 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn estT1frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never - fr15never worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist5a calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn estT1frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist5b calcage i.BlackAA i.Native i.Asian i.Otherrace i.hispaniclatino i.male i.married i.education i.foreignborn estT1frac i.selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed i.hheveraudited i.haventfiledtaxes i.preptaxesself pcaught prob_deduction i.actor_more fr_never fr2 i.worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist6 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never - fr15never worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist6a calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d
global xlist6b calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d

global xlist7 calcage i.BlackAA i.Native i.Asian i.Otherrace i.hispaniclatino i.male i.married i.education i.foreignborn i.selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed i.hheveraudited i.haventfiledtaxes i.preptaxesself pcaught prob_deduction i.actor_more fr_never fr2 i.worthpayingtaxes taxesimportant_c taxesimportant_d


*main correlation calculations
cor T1 calcage BlackAA - Otherrace hispaniclatino male married education foreignborn estT1frac selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed hheveraudited haventfiledtaxes preptaxesself pcaught prob_deduction actor_more fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d [aw = weight]
*cor absdiffT1frac calcage BlackAA - Otherrace hispaniclatino male married education foreignborn selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed hheveraudited haventfiledtaxes preptaxesself pcaught prob_deduction actor_more fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d [aw = weight]
*cor T1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn MTR1 pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d [aw = weight]
*pcorr T1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn estT1frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d [aw=weight]

*Estimating partial correlation between T and estT
svy: reg T1 $xlist5a
svy: reg T1 $xlist5b //all other indep variables but estT1frac
predict resotheriv, residuals
svy: reg estT1frac $xlist5b //regressing estT against all other indep variables
predict resestT1frac, residuals
corr resotheriv resestT1frac
*partial correlation was positive 0.1220

*Estimating partial correlation between T and MRT
svy: reg T1 $xlist6a
svy: reg T1 $xlist6b //all other indep variables but estT1frac
predict resotherivMTR, residuals
svy: reg MTR1 $xlist6b //regressing estT against all other indep variables
predict resMTR1, residuals
corr resotherivMTR resMTR1
*partial correlation was positive but very small 0.0546

/*other correlations calculations
cor T1 A1 P1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn estT1frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr11never - fr15never worthpayingtaxes taxesimportant_c taxesimportant_d [aw = weight]
cor T1 A1 P1 calcage BlackAA - Otherrace hispaniclatino male married education prob_deduction foreignborn estT1frac pcaught prop_altersaudited prop_alters_tTaxes alterselfemployed selfemployed2 hheveraudited haventfiledtaxes preptaxesself actor_less fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d [aw = weight]
*/

*Box-Cox test to determine relationship between X*beta and E(y|X)
boxcox T1 $xlist5a if T1 >0
boxcox T1 $xlist6a if T1 >0
*The results show that the relationship might be square root one since theta is close to 0.5 (0.4479).

gen sqrtT1 = sqrt(T1)

*GLM Family Test
svy: glm T1 $xlist5a, family(gamma) link(log)
predict xbetahatt, xb
gen rawresidt = T1 - exp(xbetahatt)
gen rawvart = rawresidt^2
svy: glm rawvart xbetahatt, family(gamma) link(log)
*Results indicate that the distribution is something between Poisson and Gamma

*Sqrt T1 models
glm T1 $xlist5b [pw=weight], family(gamma) link(pow 0.5)
estat ic
svy: glm T1 $xlist5, family(gamma) link(pow 0.5)
linktest


*main LPMs
svy: reg T1 $xlist5a
linktest
ovtest
reg T1 $xlist5b [pw=weight] //yields slightly different se-s, but allows to calculate AIC and BIC
estat ic
linktest
ovtest

svy: reg T1 $xlist6
linktest
ovtest

reg T1 $xlist5a [pw=weight] //yields slightly different se-s, but allows to calculate AIC and BIC
estat ic
linktest
ovtest

svy: reg sqrtT1 $xlist5a
linktest
ovtest

reg sqrtT1 $xlist5b [pw=weight] //yields slightly different se-s, but allows to calculate AIC and BIC
estat ic
linktest
ovtest

svy: reg sqrtT1 $xlist6
linktest
ovtest

reg sqrtT1 $xlist6 [pw=weight] //yields slightly different se-s, but allows to calculate AIC and BIC
estat ic
linktest
ovtest

*main fractional response models
*main probit
svy: glm T1 $xlist5a, link (p) family(binomial)
glm T1 $xlist5b [pw=weight], link (p) family(binomial) //same results, but allows to calculate AIC and BIC
linktest
estat ic

svy: glm T1 $xlist6, link (p) family(binomial)
glm T1 $xlist6 [pw=weight], link (p) family(binomial) //same results, but allows to calculate AIC and BIC
estat ic
fracreg probit T1 $xlist5b [pw = weight], vce(robust) //yields the same results as svy:glm in this case


*main probit with heterescedasticity
fracreg probit T1 $xlist5 [pw = weight], vce(robust) het($xlist5)
estat ic
fracreg probit T1 $xlist6 [pw = weight], vce(robust) het($xlist6)
estat ic

*main logit
svy: glm T1 $xlist5a, link (l) family(binomial)
linktest
glm T1 $xlist5b [pw=weight], link (l) family(binomial)
linktest
estat ic

svy: glm T1 $xlist6, link (l) family(binomial)
glm T1 $xlist6 [pw=weight], link (l) family(binomial)
linktest
estat ic

fracreg logit T1 $xlist5 [pw = weight], vce(robust) //yields the same results as svy:glm in this case
estat ic

*main loglog
svy: glm T1 $xlist5a, link (loglog) family(binomial)
svy: glm T1 $xlist6, link (loglog) family(binomial)
linktest

glm T1 $xlist5b [pw=weight], link (loglog) family(binomial) //yields the same result as svy, but allows to estimate AIC and BIC
estat ic
margins, dydx(*)
glm T1 $xlist6 [pw=weight], link (loglog) family(binomial) //yields the same result as svy, but allows to estimate AIC and BIC
estat ic

*main cloglog
svy: glm T1 $xlist5a, link (cloglog) family(binomial)
svy: glm T1 $xlist6, link (cloglog) family(binomial)
linktest

glm T1 $xlist5b [pw=weight], link (cloglog) family(binomial) //yields the same result as svy, but allows to estimate AIC and BIC
estat ic

glm T1 $xlist6 [pw=weight], link (cloglog) family(binomial) //yields the same result as svy, but allows to estimate AIC and BIC
estat ic

*Absolute difference score model and alternatives
svy: reg absdiffT1frac $xlist7
reg absdiffT1frac $xlist7 [pw=weight]
estat ic
svy: reg T1 $xlist7
svy: reg estT1frac $xlist7


******************** Sebastian's hypothesis regarding overestimating T by worthpayingtaxes ********************
ttest T1, by(worthpayingtaxes)
ttest T1, by(notworthpayingtaxes)
cor T1 taxesimportant_c //results do not support the hypothesis that those who think that it is worth paying taxes do not overestimate taxes as much as the rest.

ttest pcaught, by(worthpayingtaxes) //affect heuristic
ttest A1, by(worthpayingtaxes) //affect heuristic

ttest A1, by(incover200k)
ttest A1, by(selfemployed2)

gen Tzero = 1 if T == 0
replace Tzero = 0 if T > 0 & T != .
tab hhincome1 Tzero, m chi2 //chi-square test for the independence between income groups and Tzero
tab T hhincome1, m chi2
ttest hhincome1, by(Tzero)


*************************** Susann's hypothesis regarding "rational inattention" ***************************
*Fig.1 with only preptaxesself
hist A [fw = int_weights] if preptaxesself == 1, percent bin(25) title("Distribution of Perceived Audit Rates") xtitle("Perceived Audit Rate (percent)") addplot(pci 0 0.7 23 0.7, lpattern(dash) lwidth(medthick)) legend(label(2 "actual audit rate") order(2)) saving(Histogram_A_with_vlineWEIGHTSPrep, replace)

*Fig.2 with only preptaxesself
hist wP [fw = int_weights] if preptaxesself == 1, percent bin(65) title("Distribution of Perceived Penalty Rates") xtitle("Perceived Penalty Rate (percent)") addplot(pci 0 75 46 75, lpattern(dash) lwidth(medthick)|| pci 0 40 46 40, lcolor(red) lpattern(dash_dot) lwidth(medthick) || pci 0 20 46 20, lcolor(dark blue) lpattern(longdash_dot) lwidth(medthick)) legend(label(2 "fraud penalty rate") label(3 "accuracy-related penalty rate (high)") label(4 "typically applied penalty rate") order(4 3 2)) saving(HistogramWP_with_vlineAllWEIGHTS, replace)

*Fig.3 with only preptaxesself
twoway(histogram T [fw = int_weights] if preptaxesself == 1, percent width(2) color(green)) (histogram estT1 [fw = int_weights] if preptaxesself == 1, percent width(2) fcolor(none) lcolor(black)), title("Distribution of Perceived and Estimated Effective Tax Rates") xtitle("Effective Tax Rate (percent)") legend(order(1 "perceived" 2 "estimated actual")) saving(HistogramT, replace)

svy: tab A if preptaxesself == 1

*Table 5: with only preptaxesself
svy: reg diffA1 if preptaxesself == 1 //calculates t-test for H0: A == 0.7
svy: reg diffA2 if preptaxesself == 1 //calculates t-test for H0: A == 0.878

*Table 6: with only preptaxesself
svy: tab P if preptaxesself == 1
tab P if preptaxesself == 1
*One sample sign test for P based on weight variable
su weight if P != . & preptaxesself == 1
scalar Pop_Sizea = round(r(sum))

su weight if P < 75 & preptaxesself == 1
scalar Below75a = round(r(sum))
su weight if P < 40 & preptaxesself == 1
scalar Below40a = round(r(sum))
su weight if P < 20 & preptaxesself == 1
scalar Below20a = round(r(sum))

su weight if P == 75 & preptaxesself == 1
scalar Equal75a = round(r(sum))
su weight if P == 40 & preptaxesself == 1
scalar Equal40a = round(r(sum))
su weight if P == 20 & preptaxesself == 1
scalar Equal20a = round(r(sum))

su weight if P > 75 & P != . & preptaxesself == 1
scalar Above75a = round(r(sum))
su weight if P > 40 & P != . & preptaxesself == 1
scalar Above40a = round(r(sum))
su weight if P > 20 & P != . & preptaxesself == 1
scalar Above20a = round(r(sum))

di "Below75a= " Below75a "; " "Equal75a= " Equal75a "; " "Above75a= " Above75a
di "Below40a= " Below40a "; " "Equal40a= " Equal40a "; " "Above40a= " Above40a
di "Below20a= " Below20a "; " "Equal20a= " Equal20a "; " "Above20a= " Above20a

bitesti (Below75a+Above75a) Below75a 0.5 //H0:P >= 75; H1:P < 75 (also for two-tailed test: H0:P = 75; H1:P != 75)
bitesti (Below40a+Above40a) Below40a 0.5 //H0:P >= 40; H1:P < 40 (also for two-tailed test: H0:P = 40; H1:P != 40)
bitesti (Below20a+Above20a) Below20a 0.5 //H0:P >= 20; H1:P < 20 (also for two-tailed test: H0:P = 20; H1:P != 20)


*Table 7: with only preptaxesself
svy: reg diffT1 if preptaxesself == 1 //calculates t-test for the differences between estimated actual and perceived tax rates
svy: tab diffT1 if preptaxesself == 1

*Table 8: with only preptaxesself
cor T estT1 MT1 if preptaxesself == 1 [aw=weight] //correlations coefficients are positive now but they are still very weak.
spearman estT1 MT1 T if preptaxesself == 1, stats (rho p)
ktau estT1 MT1 T if preptaxesself == 1, stats(taua taub p)

log using Ch2preptaxesself, replace

//TABLE 10
*Table 10: A models with only preptaxesslef
global xlistA1 calcage BlackAA - Otherrace hispaniclatino male married education foreignborn MTR1 selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed hheveraudited prob_deduction actor_more fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d

reg A1 $xlistA1 if preptaxesself == 1 [pw =weight]
estat ic
glm A1 $xlistA1 if preptaxesself == 1 [pw= weight], link (l) family(binomial) nolog
estat ic
glm A1 $xlistA1 if preptaxesself == 1 [pw=weight], family(gamma) link(loglog) nolog
estat ic
glm A1 $xlistA1 if preptaxesself == 1 [pw=weight], family(gamma) link(cloglog) nolog
estat ic



//TABLE 11
*Table 11: P models with only preptaxesself
global xlistP1 calcage BlackAA - Otherrace hispaniclatino male married education foreignborn MTR1 selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed hheveraudited pcaught prob_deduction actor_more fr_never fr2 worthpayingtaxes taxesimportant_c taxesimportant_d
global xlistP2 calcage i.BlackAA i.Native i.Asian i.Otherrace i.hispaniclatino i.male i.married i.education i.foreignborn MTR1 i.selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed i.hheveraudited pcaught prob_deduction i.actor_more fr_never fr2 i.worthpayingtaxes taxesimportant_c taxesimportant_d


reg P1 $xlistP1 if preptaxesself == 1 [pw = weight]
estat ic
reg lnP1 $xlistP1 if preptaxesself == 1 [pw = weight]
estat ic
glm P1 $xlistP1 if preptaxesself == 1 [pw = weight], family(gamma) link(log)
estat ic




//TABLE 12
*Table 12: simple logit model for P with only preptaxesself
svy: logit estP $xlistP2 if preptaxesself == 1
margins, dydx(*)




//TABLE 13
*Table 13: mlogit model for P with only preptaxesself
svy: mlogit estimationP $xlistP2 if preptaxesself == 1, baseoutcome(2)
svy: mlogit, rrr

margins, dydx(*) predict(outcome(2)) //average marginal effects
margins, dydx(*) predict(outcome(1)) //underestimating
margins, dydx(*) predict(outcome(3)) //overestimating




//TABLE 14
*Table 14: Models for T with only preptaxesself
global xlistT1 calcage i.BlackAA i.Native i.Asian i.Otherrace i.hispaniclatino i.male i.married i.education i.foreignborn estT1frac i.selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed i.hheveraudited pcaught prob_deduction i.actor_more fr_never fr2 i.worthpayingtaxes taxesimportant_c taxesimportant_d
global xlistT2 calcage i.BlackAA i.Native i.Asian i.Otherrace i.hispaniclatino i.male i.married i.education i.foreignborn i.selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed i.hheveraudited pcaught prob_deduction i.actor_more fr_never fr2 i.worthpayingtaxes taxesimportant_c taxesimportant_d

reg T1 $xlistT1 if preptaxesself == 1 [pw=weight] //yields slightly different se-s, but allows to calculate AIC and BIC
estat ic
svy: reg absdiffT1frac $xlistT2 if preptaxesself == 1 

log close
*svyset, clear
*To Do list
