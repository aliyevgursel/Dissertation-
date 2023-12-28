//ANALYSIS FOR CHAPTER 4
/*CONTENT:
SECTION I: DATA CLEANING --------------------- LINES: 9 - 694
SECTION II: ANALYSIS ------- LINES: 701 - 844
*/

//SECTION I
//DATA CLEANING SECTION
use "C:\Users\galiyev\Documents\Dissertation\Chapter 3\Analysis\Numeracy data\ms32numeracyonly.dta", replace
sort prim_key
save Data2, replace

use "C:\Users\galiyev\Documents\Dissertation\Chapter 3\Analysis\Numeracy data\ms430numeracyonly.dta", replace
sort prim_key
save Data3, replace


use "C:\Users\galiyev\Documents\Dissertation\Chapter 2\ms456\ALP_MS456_2017_01_19_04_40_42_weighted.dta", replace
set more off
sort prim_key


*dropping a test case 65:2 and replacing 10% in A0
drop if prim_key == "65:2"
replace perceivedauditrate = "10" if perceivedauditrate == "10%"

************************** Destringing some string variables which were supposed to be numeric **************************
replace perceivedunderreporttaxhigher = "0" if perceivedunderreporttaxhigher == "00" | perceivedunderreporttaxhigher == "0o"
destring perceivedunderreporttaxhigher, replace

replace perceivedevasionratepopulation = "0" if perceivedevasionratepopulation == "00-"
destring perceivedevasionratepopulation, replace

************************** Generating baseline E, A, P and T **************************

*destringing A- perceived audit rate variable
destring perceivedauditrate, replace //converting perceivedauditrate variable into a numeric variable

*replacing values with magnified audit values. Taking midpoints of the magnifier interval. Only those respondents who have inconsistent ms456_perceivedauditrate and ms456_peer
replace perceivedauditrate = 1 if perceivedauditrate == 0 & perceivedauditratemagnifier == 6
replace perceivedauditrate = 0.55 if perceivedauditrate == 0 & perceivedauditratemagnifier == 5
replace perceivedauditrate = 0.0055 if perceivedauditrate == .02 & perceivedauditratemagnifier == 3
replace perceivedauditrate = 0.0005 if perceivedauditrate == .05 & perceivedauditratemagnifier == 2
replace perceivedauditrate = 0.055 if perceivedauditrate == 0.5 & perceivedauditratemagnifier == 4
replace perceivedauditrate = 0.055 if perceivedauditrate == .5 & perceivedauditratemagnifier == 4
replace perceivedauditrate = 0.055 if perceivedauditrate == 1 & perceivedauditratemagnifier == 4
replace perceivedauditrate = 0.0055 if perceivedauditrate == 1 & perceivedauditratemagnifier == 3
replace perceivedauditrate = 0.0005 if perceivedauditrate == 1 & perceivedauditratemagnifier == 2
replace perceivedauditrate = 0 if perceivedauditrate == . & perceivedauditratemagnifier == 1
replace perceivedauditrate = 0.0005 if perceivedauditrate == . & perceivedauditratemagnifier == 2


gen double P0 = perceivedpenaltyrate/1000
gen double T0 = perceivedtaxrate/100
gen double A0 = perceivedauditrate/100
gen double E0 = perceivedevasionrate/100
gen double pcaught = perceivedcaught/100
gen double Epop = perceivedevasionratepopulation/100

************************ Winsorizing A, P and T *************************
su T0, detail //0.5 is the 95-percentile
su P0, detail //1.3 is the 95-percentile
su A0, detail //0.5 is the 95-percentile


*WINSORIZING SWITCHES
*replace T0 = 0.5 if T0 > 0.5 & T0 != .
replace P0 = 4 if P0 > 4 & P0 != .
*replace A0 = 0.5 if A0 > 0.5 & A0 != .


************************** Generating Tax and Evasion rates for Tax Rate Scenarios **************************
*Generating tax rate variables for hypothetical case 1 //first questions of Sect. 7, Condition A and Condition B//and case 2 //second questions of Sect. 7, Condition A and Condition B//
gen T1 = 1.5*perceivedtaxrate/100 if perceivedunderreporttaxhigher != . //tax rates in the 1st question of Sect. 7, Condition A.
replace T1 = 0.75*perceivedtaxrate/100 if perceivedunderreporttaxlower != . //tax rates in the 1st question of Sect. 7, Condition B.

gen T2 = 2*perceivedtaxrate/100 if perceivedunderreporttaxmuchhighe != . //tax rates in the 2nd question of Sect. 7, Condition A.
replace T2 = 0.5*perceivedtaxrate/100 if perceivedunderreporttaxmuchlower != . //tax rates in the 2nd question of Sect. 7, Condition B.

gen E1 = perceivedunderreporttaxhigher/100 if perceivedunderreporttaxhigher != .
replace E1 = perceivedunderreporttaxlower/100 if perceivedunderreporttaxlower != .
gen E2 = perceivedunderreporttaxmuchhighe/100 if perceivedunderreporttaxmuchhighe != .
replace E2 = perceivedunderreporttaxmuchlower/100 if perceivedunderreporttaxmuchlower != .

*Generating binary variable taxcondition = 1 if higher tax scenarios offered; = 0 if lower tax scenarios offered
gen taxcondition = .
replace taxcondition = 1 if perceivedevasionrate == 0
replace taxcondition = 1 if behavreactionrandom == 1 & perceivedevasionrate != 100
replace taxcondition = 0 if perceivedevasionrate == 100
replace taxcondition = 0 if behavreactionrandom == 2 & perceivedevasionrate != 0

label define conditionL 0 "Cond.B-lower" 1 "Cond.A-higher"
label values taxcondition conditionL

gen randomtaxincrease = .
replace randomtaxincrease = 1 if taxcondition == 1 & perceivedevasionrate != 0
replace randomtaxincrease = 0 if taxcondition == 0 & perceivedevasionrate != 100

label define randomconditionL 0 "Tax decrease" 1 "Tax increase"
label values randomtaxincrease randomconditionL


************************** Generating Audit and Evasion rates for Audit Rate Scenarios **************************
*Generating audit rates for hypothetical case 3 and case 4
gen A3 = 2*perceivedauditrate/100 //audit rates in the 1st scenario of Sect. 8
gen A4 = 3*perceivedauditrate/100 //audit rate in the 2nd scenario of Sect. 8

*Generating Evasion rates for Audit Rate Scenarios
gen E3 = perceivedunderreportaudithigher/100
gen E4 = perceivedunderreportauditmuchhig/100


************************** Generating Penalty and Evasion rates for Penalty Rate Scenarios **************************
*Generating penalty rates for hypothetical case 5 //first questions of Sect. 9, Condition A and Condition B// and case 6 //second questions of Sect. 9, Condition A and Condition B//
gen P5 = 1.5*P0 if perceivedunderreportpenaltyhighe != . //penalty rates in the 1st question of Sect. 9, Condition A.
replace P5 = 0.5*P0 if perceivedunderreportpenaltymuchl != . //penalty rates in the 1st question of Sect. 9, Condition B.

gen P6 = 2*P0 if perceivedunderreportpenaltymuchh != . //penalty rates in the 2nd question of Sect. 9, Condition A.
replace P6 = 0.75*P0 if perceivedunderreportpenaltylower != . //penalty rates in the 2nd question of Sect. 9, Condition B.

*Generating Evasion rates for Penalty Scenarios
gen E5 = perceivedunderreportpenaltyhighe/100 if perceivedunderreportpenaltyhighe != .
replace E5 = perceivedunderreportpenaltymuchl/100 if perceivedunderreportpenaltymuchl != .
gen E6 = perceivedunderreportpenaltymuchh/100 if perceivedunderreportpenaltymuchh != .
replace E6 = perceivedunderreportpenaltylower/100 if perceivedunderreportpenaltylower != .


*Generating binary variable pencondition = 1 if higher penalty scenarios offered; = 0 if lower penalty scenarios offered
gen pencondition = .
replace pencondition = 0 if perceivedevasionrate == 0
replace pencondition = 0 if behavreactionrandom == 2 & perceivedevasionrate != 100
replace pencondition = 1 if perceivedevasionrate == 100
replace pencondition = 1 if behavreactionrandom == 1 & perceivedevasionrate != 0

label values pencondition conditionL

gen randompencondition = .
replace randompencondition = 1 if pencondition == 1 & perceivedevasionrate != 100
replace randompencondition = 0 if pencondition == 0 & perceivedevasionrate != 0

label values randompencondition randomconditionL


************************ Flagging "inconsistent" scenarios  *************************
*Section 7A- the difference have to be positive for the "consistency"
gen dif7a1 = perceivedunderreporttaxmuchhighe - perceivedunderreporttaxhigher
gen dif7a2 = perceivedunderreporttaxhigher - perceivedevasionrate
gen dif7a3 = perceivedunderreporttaxmuchhighe - perceivedevasionrate

gen flag7a1 = (dif7a1 < -5)
gen flag7a2 = (dif7a2 < -5)
gen flag7a3 = (dif7a3 < -5)

*Section 7B - the difference have to be positive for the "consistency"
gen dif7b1 = perceivedunderreporttaxlower - perceivedunderreporttaxmuchlower
gen dif7b2 = perceivedevasionrate - perceivedunderreporttaxlower
gen dif7b3 = perceivedevasionrate - perceivedunderreporttaxmuchlower

gen flag7b1 = (dif7b1 < -5)
gen flag7b2 = (dif7b2 < -5)
gen flag7b3 = (dif7b3 < -5)

gen flaginconsistenttax = (dif7a1 < -5 | dif7a2 < -5 | dif7a3 < -5 | dif7b1 < -5 | dif7b2 < -5 | dif7b3 < -5)

*Section 8 - the difference have to be positive for the "consistency"
gen dif8_1 = perceivedunderreportaudithigher - perceivedunderreportauditmuchhig
gen dif8_2 = perceivedevasionrate - perceivedunderreportaudithigher
gen dif8_3 = perceivedevasionrate - perceivedunderreportauditmuchhig

gen flag8_1 = (dif8_1 < -5)
gen flag8_2 = (dif8_2 < -5)
gen flag8_3 = (dif8_3 < -5)

gen flag43 = (dif8_1 < -5)
gen flag30 = (dif8_2 < -5)
gen flag40 = (dif8_3 < -5)
gen flaginconsistentaudit = (dif8_1 < -5 | dif8_2 < -5 | dif8_3 < -5)

*Section 9A - the difference have to be positive for the "consistency"
gen dif9a1 = perceivedunderreportpenaltyhighe - perceivedunderreportpenaltymuchh
gen dif9a2 = perceivedevasionrate - perceivedunderreportpenaltyhighe
gen dif9a3 = perceivedevasionrate - perceivedunderreportpenaltymuchh

gen flag9a1 = (dif9a1 < -5)
gen flag9a2 = (dif9a2 < -5)
gen flag9a3 = (dif9a3 < -5)

*Section 9B - the differences have to be positive for the "consistency"
gen dif9b1 = perceivedunderreportpenaltymuchl - perceivedunderreportpenaltylower
gen dif9b2 = perceivedunderreportpenaltylower - perceivedevasionrate
gen dif9b3 = perceivedunderreportpenaltymuchl - perceivedevasionrate

gen flag9b1 = (dif9b1 < -5)
gen flag9b2 = (dif9b2 < -5)
gen flag9b3 = (dif9b3 < -5)

gen flaginconsistent = (dif7a1 < -5 | dif7a2 < -5 | dif7a3 < -5 | dif7b1 < -5 | dif7b2 < -5 | dif7b3 < -5 | dif8_1 < -5 | dif8_2 < -5 | dif8_3 < -5 | dif9a1 < -5 | dif9a2 < -5 | dif9a3 < -5 | dif9b1 < -5 | dif9b2 < -5 | dif9b3 < -5)
gen flaginconsistentpen = (dif9a1 < -5 | dif9a2 < -5 | dif9a3 < -5 | dif9b1 < -5 | dif9b2 < -5 | dif9b3 < -5)

************************ Flagging missing values  *************************
gen flag10 = (E0 == . | E1 == . | T0 == . | T1 == .)
gen flag20 = (E0 == . | E2 == . | T0 == . | T2 == .)
gen flag21 = (E1 == . | E2 == . | T1 == . | T2 == .)

gen flag50 = (E0 == . | E5 == . | P0 == . | P5 == .)
gen flag60 = (E0 == . | E6 == . | P0 == . | P6 == .)
gen flag65 = (E5 == . | E6 == . | P5 == . | P6 == .)


************************ Generating Effective Tax Rate *************************
gen hhincome1 = familyincome
replace hhincome1 = . if familyincome < 14 & familyincome_part2 != .
replace hhincome1 = 15 if familyincome == 14 & familyincome_part2 == 2
replace hhincome1 = 16 if familyincome == 14 & familyincome_part2 == 3
replace hhincome1 = 17 if familyincome == 14 & familyincome_part2 == 4

label define hhincomeL 1 "< $5,000" 2 "$5,000 to $7,499" 3 "$7,500 to $9,999" 4 "$10,000 to $12,499" 5 "$12,500 to $14,999" 6 "$15,000 to $19,999" 7 "$20,000 to $24,999" 8 "$25,000 to $29,999" 9 "$30,000 to $34,999" 10 "$35,000 to $39,999" 11 "$40,000 to $49,999" 12 "$50,000 to $59,999" 13 "$60,000 to $74,999" 14 "$75,000 to $99,999" 15 "$100,000 to $124,999" 16 "$125,000 to $199,999" 17 "$200,000 and more"
label values hhincome1 hhincomeL

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

*Generating marginal tax rates based on hhincome
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



**************************** Data cleaning for the Regression Analyses ****************************
*Transforming rate variables (like A,P and T) into fraction for fracreg models
gen double estT1frac = estT1/100

gen double MTR1 = MT1/100

gen double  prob_deduction= refunddebt/100

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



*Generating a numeric variable for family income based on familyincome and familyincome_part2 variables
*Mean values for the income categories were taken from CPS_2015_family_income.csv and used in the replacements, unless noted otherwise.
gen income = 1249 if familyincome == 1
replace income = 6250 if familyincome == 2 // used the midpoint of the category
replace income = 8750 if familyincome == 3 // used the midpoint of the category
replace income = 11250 if familyincome == 4 // used the midpoint of the category
replace income = 13750 if familyincome == 5 // used the midpoint of the category
replace income = 17278 if familyincome == 6
replace income = 22165 if familyincome == 7
replace income = 27186 if familyincome == 8
replace income = 32085 if familyincome == 9
replace income = 37183 if familyincome == 10
replace income = (42013 * 0.0473867360953127 + 47198 * 0.0415645037621226) / (0.0473867360953127 + 0.0415645037621226) if familyincome == 11
replace income = (51984 * 0.0428705037789742 + 57154 * 0.0354136649730795) / (0.0428705037789742 + 0.0354136649730795) if familyincome == 12
replace income = (61941 * 0.0371746585441891 + 67095 * 0.0301559616794318 + 72042 * 0.031756864925895) / (0.0371746585441891 + 0.0301559616794318 + 0.031756864925895) if familyincome == 13
replace income = (77007 * 0.0262716648551183 + 81979 * 0.0264823100191266 + 87142 * 0.0225811615816924 + 92009 * 0.0211993293057978 + 97155 * 0.0177784518423026) / (0.0262716648551183 + 0.0264823100191266 + 0.0225811615816924 + 0.0211993293057978 + 0.0177784518423026) if familyincome == 14 & familyincome_part2 == 1
replace income = (101830 * 0.0210476647877118 + 107162 * 0.0149810840642721 + 111973 * 0.0150147872905134 + 117204 * 0.0124701937092928 + 121842 * 0.0123859356436895) / (0.0210476647877118 + 0.0149810840642721 + 0.0150147872905134 + 0.0124701937092928 + 0.0123859356436895) if familyincome == 14 & familyincome_part2 == 2
replace income = (127026 * 0.0104732775544939 + 132066 * 0.0104142969085716 + 137202 * 0.0089145033408323 + 141989 * 0.00820673558976433 + 146959 * 0.00659740653674073 + 151788 * 0.00828256784880733 + 157072 * 0.00565371620198343 + 162151 * 0.00535881297237178 + 167076 * 0.00455836134914015 + 171948 * 0.00467632264098481 + 177161 * 0.00397698069647717 + 181956 * 0.00390957424399451 + 187307 * 0.00282264519771155 + 192029 * 0.00301643874859921 + 197119 * 0.00244348390249657) / (0.0104732775544939 + 0.0104142969085716 + 0.0089145033408323 + 0.00820673558976433 + 0.00659740653674073 + 0.00828256784880733 + 0.00565371620198343 + 0.00535881297237178 + 0.00455836134914015 + 0.00467632264098481 + 0.00397698069647717 + 0.00390957424399451 + 0.00282264519771155 + 0.00301643874859921 + 0.00244348390249657) if familyincome == 14 & familyincome_part2 == 3
replace income = (219377 * 0.0180565034587936 + 398194 * 0.0209297034958671) / (0.0180565034587936 + 0.0209297034958671) if familyincome == 14 & familyincome_part2 == 4

*numerical income variable with removed inconsistent observations (90 observations)
gen income1 = 1249 if hhincome1 == 1
replace income1 = 6250 if hhincome1 == 2 // used the midpoint of the category
replace income1 = 8750 if hhincome1 == 3 // used the midpoint of the category
replace income1 = 11250 if hhincome1 == 4 // used the midpoint of the category
replace income1 = 13750 if hhincome1 == 5 // used the midpoint of the category
replace income1 = 17278 if hhincome1 == 6
replace income1 = 22165 if hhincome1 == 7
replace income1 = 27186 if hhincome1 == 8
replace income1 = 32085 if hhincome1 == 9
replace income1 = 37183 if hhincome1 == 10
replace income1 = (42013 * 0.0473867360953127 + 47198 * 0.0415645037621226) / (0.0473867360953127 + 0.0415645037621226) if hhincome1 == 11
replace income1 = (51984 * 0.0428705037789742 + 57154 * 0.0354136649730795) / (0.0428705037789742 + 0.0354136649730795) if hhincome1 == 12
replace income1 = (61941 * 0.0371746585441891 + 67095 * 0.0301559616794318 + 72042 * 0.031756864925895) / (0.0371746585441891 + 0.0301559616794318 + 0.031756864925895) if hhincome1 == 13
replace income1 = (77007 * 0.0262716648551183 + 81979 * 0.0264823100191266 + 87142 * 0.0225811615816924 + 92009 * 0.0211993293057978 + 97155 * 0.0177784518423026) / (0.0262716648551183 + 0.0264823100191266 + 0.0225811615816924 + 0.0211993293057978 + 0.0177784518423026) if hhincome1 == 14
replace income1 = (101830 * 0.0210476647877118 + 107162 * 0.0149810840642721 + 111973 * 0.0150147872905134 + 117204 * 0.0124701937092928 + 121842 * 0.0123859356436895) / (0.0210476647877118 + 0.0149810840642721 + 0.0150147872905134 + 0.0124701937092928 + 0.0123859356436895) if hhincome1 == 15
replace income1 = (127026 * 0.0104732775544939 + 132066 * 0.0104142969085716 + 137202 * 0.0089145033408323 + 141989 * 0.00820673558976433 + 146959 * 0.00659740653674073 + 151788 * 0.00828256784880733 + 157072 * 0.00565371620198343 + 162151 * 0.00535881297237178 + 167076 * 0.00455836134914015 + 171948 * 0.00467632264098481 + 177161 * 0.00397698069647717 + 181956 * 0.00390957424399451 + 187307 * 0.00282264519771155 + 192029 * 0.00301643874859921 + 197119 * 0.00244348390249657) / (0.0104732775544939 + 0.0104142969085716 + 0.0089145033408323 + 0.00820673558976433 + 0.00659740653674073 + 0.00828256784880733 + 0.00565371620198343 + 0.00535881297237178 + 0.00455836134914015 + 0.00467632264098481 + 0.00397698069647717 + 0.00390957424399451 + 0.00282264519771155 + 0.00301643874859921 + 0.00244348390249657) if hhincome1 == 16
replace income1 = (219377 * 0.0180565034587936 + 398194 * 0.0209297034958671) / (0.0180565034587936 + 0.0209297034958671) if hhincome1 == 17

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


*Generating an aggregate variable for fr11-fr15 variables
gen fr_never = fr11never + fr12never + fr13never + fr14never + fr15never
egen fr_never2 = rowtotal(fr11never fr12never fr13never fr14never fr15never), missing


*Generating an aggregate variable for fr21-fr25 questions
egen fr2 = rowmean(fr21-fr25)

*Generating binary variables from the categories for the "actor" variable
gen actor_more = 0 
replace actor_more = 1 if actor <= 2 //much or somewhat more likely to fully report = 1, and = 0 if otherwise


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


**************************** Merging the dataset with ms32numeracyonly data ****************************
save Data1, replace

merge 1:1 prim_key using Data2
drop if _merge == 2
sort prim_key
drop _merge
save Data1, replace

merge 1:1 prim_key using Data3
drop if _merge == 2

*Generating nu1 variable (= 1 if correct, 0 if incorrect response given to a01 and/or n01)
gen n1 = .
replace n1 = 0 if n01 != ""
replace n1 = 1 if n01 == "500" | n01 == "50%"

gen a1 = .
replace a1 = 0 if tsend430 != "" 
replace a1 = 1 if a01 >= 490 & a01 <= 510

gen nu1 = n1
replace nu1 = 0 if a1 == 0 & n1 == .
replace nu1 = 0 if a1 == 0 & a01 != .
replace nu1 = 1 if a1 == 1 // since answers to a01 are most recent, they are taken as the main answer if n01 and a01 are different.


*Generating nu2 variable (= 1 if correct, 0 if incorrect response given to a02 and/or n02)
gen n2 = .
replace n2 = 0 if n02 != .
replace n2 = 1 if n02 == 10

gen a2 = .
replace a2 = 0 if tsend430 != ""
replace a2 = 1 if a02 == 10

gen nu2 = n2
replace nu2 = 0 if a2 == 0 & n2 == .
replace nu2 = 0 if a2 == 0 & a02 != .
replace nu2 = 1 if a2 == 1 // since answers to a02 are most recent, they are taken as the main answer if n02 and a02 are different.


*Generating nu3 variable (= 1 if correct, 0 if incorrect response given to a03 and/or n03)
gen n3 = .
replace n3 = 0 if n03 != ""
replace n3 = 1 if n03 == ",1" | n03 == ".1" | n03 == "0.1" | n03 == "0.10" | n03 == ".10" | n03 == "1/10" | n03 == "<1"

gen a3 = .
replace a3 = 0 if tsend430 != ""
replace a3 = 1 if a03 == 0.1

gen nu3 = n3
replace nu3 = 0 if a3 == 0 & n3 == .
replace nu3 = 0 if a3 == 0 & a03 != .
replace nu3 = 1 if a3 == 1 // since answers to a03 are most recent, they are taken as the main answer if n03 and a03 are different.

*Generating nu4 variable (= 1 if correct, 0 if incorrect response given to a04 and/or n08_answer2)
gen n4 = .
replace n4 = 0 if n08_answer2 != ""
replace n4 = 1 if n08_answer2 == "100"

gen a4 = .
replace a4 = 0 if tsend430 != ""
replace a4 = 1 if a04 == 100

gen nu4 = n4
replace nu4 = 0 if a4 == 0 & n4 == .
replace nu4 = 0 if a4 == 0 & a04 != .
replace nu4 = 1 if a4 == 1 // since answers to a04 are most recent, they are taken as the main answer if n08_answer2 and a04 are different.

*Generating nu5 variable (= 1 if correct, 0 if incorrect response given to a05 and/or n09)
gen n5 = .
replace n5 = 0 if n09 != ""
replace n5 = 1 if n09 == "20"

gen a5 = .
replace a5 = 0 if tsend430 != ""
replace a5 = 1 if a05 == 20

gen nu5 = n5
replace nu5 = 0 if a5 == 0 & n5 == .
replace nu5 = 0 if a5 == 0 & a05 != .
replace nu5 = 1 if a5 == 1 // since answers to a05 are most recent, they are taken as the main answer if n09 and a05 are different.


*Generating nu6 variable (= 1 if correct, 0 if incorrect response given to a06 and/or n12)
gen n6 = .
replace n6 = 0 if tsend32 != ""
replace n6 = 1 if n12 == "9" & n12_tumorchance == "18"
replace n6 = 1 if n12 == "5" & n12_tumorchance == "10"
replace n6 = 1 if n12 == "50" & n12_tumorchance == "100"

gen a6 = .
replace a6 = 0 if tsend430 != ""
replace a6 = 1 if a06_denominator == 19 & a06_numerator == 9

gen nu6 = n6
replace nu6 = 0 if a6 == 0 & n6 == .
replace nu6 = 0 if a6 == 0 & (a06_denominator != . | a06_numerator != .)
replace nu6 = 1 if a6 == 1 // since answers to a06 are most recent, they are taken as the main answer if n12 and a06 are different.


*Generating nu7 variable (= 1 if correct, 0 if incorrect response given to a07 and/or n15)
gen n7 = .
replace n7 = 0 if tsend32 != ""
replace n7 = 1 if n15 == "..05" | n15 == ".05" | n15 == "05" | n15 == "5"

gen a7 = .
replace a7 = 0 if tsend430 != ""
replace a7 = 1 if a07 == .05 | a07 == 5

gen nu7 = n7
replace nu7 = 0 if a7 == 0 & n7 == .
replace nu7 = 0 if a7 == 0 & a07 != .
replace nu7 = 1 if a7 == 1 // since answers to a07 are most recent, they are taken as the main answer if n15 and a07 are different.


*Generating nu8 variable (= 1 if correct, 0 if incorrect response given to a08 and/or n17)
gen n8 = .
replace n8 = 0 if tsend32 != ""
replace n8 = 1 if n17 == "47"

gen a8 = .
replace a8 = 0 if tsend430 != ""
replace a8 = 1 if a08 == 47

gen nu8 = n8
replace nu8 = 0 if a8 == 0 & n8 == .
replace nu8 = 0 if a8 == 0 & a08 != .
replace nu8 = 1 if a8 == 1 // since answers to a08 are most recent, they are taken as the main answer if n17 and a08 are different.


*Generating a variable for the totla number of correct answers
egen nutotal = rowtotal(nu1 nu2 nu3 nu4 nu5 nu6 nu7 nu8), missing

foreach var of varlist flaginconsistent flaginconsistenttax flaginconsistentpen flaginconsistentaudit {
tab `var' nutotal, chi2 row
tab `var' nutotal, chi2 col
}

tab preptaxesself nutotal, row chi2

save DataCleaned4RegWP99, replace

//END OF SECTION I

******************************************************************************************************************************
******************************************************************************************************************************



//SECTION II
//ANALYSIS

use "C:\Users\galiyev\Documents\Dissertation\Chapter 3\Analysis\DataCleaned4RegWP99.dta", replace //Using Winsorized data, 99 percentile threshold for the perceived penalty
sort prim_key
set more off

save Calculations, replace

*REPLACING A3 AND A4 WITH 1 IF THEY ARE > 1
replace A3 = 1 if A3 > 1 & A3 != .
replace A4 = 1 if A4 > 1 & A4 != .


**************************** Generating Long Form of the Dataset ****************************
*Generating a long form of the dataset for the panel data analysis
reshape long E T A P, i(prim_key) j(scenarios)
by prim_key (scenarios), sort: replace T = T[1] if T >= . & E != .
by prim_key (scenarios), sort: replace P = P[1] if P >= . & E != .
by prim_key (scenarios), sort: replace A = A[1] if A >= . & E != .


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


******************************** Linear Regression Models with the Panel Data ********************************
xtset id scenarios

global xlist1 calcage i.BlackAA i.Native i.Asian i.Otherrace i.hispaniclatino i.male i.married i.education i.foreignborn MTR1 i.selfemployed2 prop_altersaudited prop_alters_tTaxes alterselfemployed i.hheveraudited i.haventfiledtaxes i.preptaxesself prob_deduction i.actor_more fr_never fr2 i.worthpayingtaxes taxesimportant_c taxesimportant_d

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
*Evasion rate with intervention 1, for preptaxesself & 100% effectiveness
replace P = 0.75 if scenarios == 0 & e(sample) & preptaxesself == 1 //TURN ON THE REPLACEMENT, RECALCULATE, BUT THEN RESTORE.
margins if scenarios == 0 & e(sample) //margins after the replacement of P with 0.75 for preptaxesself == 1
restore
preserve

*Evasion rate estimate for Intervention 2 only, for preptaxesself & 100% effectiveness
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
