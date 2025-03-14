log using YuichiroTomitsuka_Log.log, replace
* our data loading and data cleaning commands
use 36158-0001-Data.dta, clear
append using 36158-0002-Data.dta
* replace the varibles to a missing value if they are -4 (don't know) or -7 (refused)
replace WM_TURN1R = . if WM_TURN1R == -4 | WM_TURN1R == -7
replace WM_JSTR2 = . if WM_JSTR2 == -4 | WM_JSTR2 == -7
replace WM_JSAT1R = . if WM_JSAT1R == -4 | WM_JSAT1R == -7
replace WM_WFC6R = . if WM_WFC6R == -4 | WM_WFC6R == -7
replace EM_DIST6R = . if EM_DIST6R == -4 | EM_DIST6R == -7
replace EM_STRS3 = . if EM_STRS3 == -4 | EM_STRS3 == -7

gen interaction = WM_JSTR2*WM_JSAT1R

save YuichiroTomitsuka_data.dta, replace

* import the dataset created above
use YuichiroTomitsuka_data.dta, clear

* run regressions and create tables
eststo reg_1: reg WM_TURN1R i.WM_JSTR2, robust
eststo reg_2: reghdfe WM_TURN1R i.WM_JSTR2, absorb(ADMINLINK) cluster(ADMINLINK)
eststo reg_3: reghdfe WM_TURN1R i.WM_JSTR2, absorb(ADMINLINK WAVE) cluster(ADMINLINK)
eststo reg_4: reghdfe WM_TURN1R i.WM_JSTR2 WM_JSAT1R WM_WFC6R EM_DIST6R EM_STRS3, absorb(ADMINLINK WAVE) cluster(ADMINLINK)
eststo reg_5: reghdfe WM_TURN1R i.WM_JSTR2 WM_WFC6R EM_DIST6R EM_STRS3, absorb(ADMINLINK WAVE) cluster(ADMINLINK)
eststo reg_6: reghdfe WM_TURN1R WM_JSTR2 WM_JSAT1R interaction WM_WFC6R EM_DIST6R EM_STRS3, absorb(ADMINLINK WAVE) cluster(ADMINLINK)
eststo reg_7: reghdfe WM_TURN1R WM_JSTR2 WM_JSAT1R interaction, absorb(ADMINLINK WAVE) cluster(ADMINLINK)
sum WM_JSTR2
gen dWM_JSTR2=WM_JSTR2-r(mean)
sum WM_JSAT1R
gen dWM_JSAT1R=WM_JSAT1R-r(mean)
gen dinteraction=dWM_JSTR2*dWM_JSAT1R
eststo reg_8: reghdfe WM_TURN1R dWM_JSTR2 dWM_JSAT1R dinteraction WM_WFC6R EM_DIST6R EM_STRS3, absorb(ADMINLINK WAVE) cluster(ADMINLINK)
esttab reg_1 reg_2 reg_3 reg_4 reg_5 reg_6 reg_7 reg_8 using table1.rtf, wrap se r2 label title(This is a regression table) addnotes("Unit of observation is employees and employers")

eststo clear

* plot the marginsplot
reghdfe WM_TURN1R i.WM_JSTR2, absorb(ADMINLINK WAVE) cluster(ADMINLINK)
margins WM_JSTR2
marginsplot, ytitle(Intention to quit job) xlabel(, labsize(vsmall)) xtitle(No decision authority at work) title(Estimated effects of intention to quit job (with 95% CIs) n=8850)



* descriptive statistics
asdoc sum WM_TURN1R WM_JSTR2 WM_JSAT1R WM_WFC6R EM_DIST6R EM_STRS3

tab WM_JSTR2, gen(indicator)
asdoc corr indicator1 indicator2 indicator3 indicator4 indicator5 WM_JSAT1R


log close
