*! 1.0.1 Tom Palmer 4aug2011
program bpbounds_examples
syntax [anything], eg(integer)

* example 1
if `eg' == 1 {
	preserve
	clear
	qui bpbounds_examples_bpdata
	local cmd "bpbounds y (x = z) [fw=count]"
	di _n in wh ". `cmd'"
	`cmd'
	restore
}

* example 2
if `eg' == 2 {
	local cmd "bpboundsi 74 11514 0 0 34 2385 12 9665"
	di _n in wh ". `cmd'"
	`cmd'
}

* example 3
if `eg' == 3 {
	preserve
	clear
	qui bpbounds_examples_bpdata
	local cmd1 "tabulate x y if z==0 [fw=count], matcell(freqz0)"
	di _n in wh ". `cmd1'"
	`cmd1'
	local cmd2 "tabulate x y if z==1 [fw=count], matcell(freqz1)"
	di _n in wh ". `cmd2'"
	`cmd2'
	local cmd3 "mat list freqz0"
	di _n in wh ". `cmd3'"
	`cmd3'
	local cmd4 "mat freqz0 = (freqz0 \ 0 , 0)"
	di _n in wh ". `cmd4'"
	`cmd4'
	local cmd5 "mat list freqz0"
	di _n in wh ". `cmd5'"
	`cmd5'
	local cmd6 "mat list freqz1"
	di _n in wh ". `cmd6'"
	`cmd6'
	local cmd7 "bpboundsi, mat(freqz0 freqz1)"
	di _n in wh ". `cmd7'"
	`cmd7'
	restore
}

* example 4
if `eg' == 4 {
	preserve
	quietly {
		clear
		set obs 6
		gen x = 0 in 1
		gen y = 0 in 1 
		gen z = 0 in 1
		gen count = 74 in 1
		replace x = 0 in 2
		replace y = 1 in 2
		replace z = 0 in 2
		replace count = 11514 in 2
		replace x = 0 in 3
		replace y = 0 in 3
		replace z = 1 in 3
		replace count = 34 in 3
		replace x = 0 in 4
		replace y = 1 in 4
		replace z = 1 in 4
		replace count = 2385 in 4
		replace x = 1 in 5
		replace y = 0 in 5
		replace z = 1 in 5
		replace count = 12 in 5
		replace x = 1 in 6
		replace y = 1 in 6
		replace z = 1 in 6
		replace count = 9665 in 6
	}
	local cmd1 "bysort z: tabulate x y [fw=count], cell"
	di _n in wh ". `cmd1'"
	`cmd1'
	local cmd2 "bpboundsi .0064 .9936 0 0 .0028 .1972 .001 .799"
	di _n in wh ". `cmd2'"
	`cmd2'
	restore
}

* example 5
if `eg' == 5 {
	preserve
	clear
	qui bpbounds_examples_bpdata
	local cmd1 "tab z y [fw=count], row matcell(zy)"
	di _n in wh ". `cmd1'"
	`cmd1'
	local cmd2 "tab z x [fw=count], row matcell(zx)"
	di _n in wh ". `cmd2'"
	`cmd2'
	local cmd3 "bpboundsi, mat(zy zx) biv"
	di _n in wh ". `cmd3'"
	`cmd3'
	restore
}

* example 6
if `eg' == 6 {
	local cmd "bpboundsi .83 .05 .11 .01 .88 .06 .05 .01 .72 .05 .20 0.03"
	di _n in wh ". `cmd'"
	`cmd'
}

end

program bpbounds_examples_bpdata
set obs 6
gen x = 0 in 1
gen y = 0 in 1 
gen z = 0 in 1
gen count = 74 in 1
replace x = 0 in 2
replace y = 1 in 2
replace z = 0 in 2
replace count = 11514 in 2
replace x = 0 in 3
replace y = 0 in 3
replace z = 1 in 3
replace count = 34 in 3
replace x = 0 in 4
replace y = 1 in 4
replace z = 1 in 4
replace count = 2385 in 4
replace x = 1 in 5
replace y = 0 in 5
replace z = 1 in 5
replace count = 12 in 5
replace x = 1 in 6
replace y = 1 in 6
replace z = 1 in 6
replace count = 9665 in 6
end
