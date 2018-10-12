*! 1.0.2 Tom Palmer 4aug2011
program bpbounds, rclass
version 9.0

_iv_parse `0'   // parses `0' of form: lhs exog (endog = inst)
local lhs `s(lhs)'
local endog `s(endog)'
local exog `s(exog)'
local inst `s(inst)'
local 0 `s(zero)'

if "`exog'" != "" {
	di as err "No exogenous variables allowed"
	error 103
}

if wordcount("`endog'") != 1 {
	di as err "Only one endogenous variable allowed"
	error 103
}

if wordcount("`inst'") != 1 {
	di as err "Only one instrumental variable allowed"
	error 103
}

syntax  [if] [in] [fweight/] [, fmt(string)]

if "`fmt'" == "" {
	local fmt %5.4f
}
	
* if, in, expand fweights
if "`if'`in'`exp'" != "" {
	preserve
	if "`if'`in'" != "" {
		qui keep `if' `in'
	}
	if "`exp'" != "" {
		qui expand `exp'
	}
}

bpbounds_trivariate `endog' `lhs' `inst', fmt(`fmt')

if "`if'`in'`exp'" != "" {
	restore
}

ret add

end


program bpbounds_trivariate, rclass
syntax varlist(min=3 max=3 numeric)[, fmt(string)]
tokenize `varlist'
local x `1'
local y `2'
local z `3'

* check x y are 0,1 and z is 0,1 or 0,1,2 
qui foreach var of varlist `x' `y' {
	levelsof `var', local(levels)
	if "`levels'" != "0 1" {
		di as err "`var' not coded 0,1"
		error 197
	}
}
qui levelsof `z', local(levels)
if "`levels'" != "0 1" {
	if "`levels'" != "0 1 2" {
		di as err "`z' not coded as 0,1 or 0,1,2"
		error 197
	}
}
tempname nzcat
sca `nzcat' = wordcount("`levels'")

if `nzcat' == 2 {
	* notation: P(y=0,x=0|z=0)=p000
	tempname n000 n100 n010 n110 n001 n101 n011 n111
	qui count if `z' == 0 & `x' == 0 & `y' == 0
	sca `n000' = r(N)
	qui count if `z' == 0 & `x' == 0 & `y' == 1
	sca `n100' = r(N)
	qui count if `z' == 0 & `x' == 1 & `y' == 0
	sca `n010' = r(N)
	qui count if `z' == 0 & `x' == 1 & `y' == 1
	sca `n110' = r(N)

	qui count if `z' == 1 & `x' == 0 & `y' == 0
	sca `n001' = r(N)
	qui count if `z' == 1 & `x' == 0 & `y' == 1
	sca `n101' = r(N)
	qui count if `z' == 1 & `x' == 1 & `y' == 0
	sca `n011' = r(N)
	qui count if `z' == 1 & `x' == 1 & `y' == 1
	sca `n111' = r(N)

	bpboundsi `n000' `n100' `n010' `n110' `n001' `n101' `n011' `n111', ///
		fmt(`fmt') 
	ret add
}
else if `nzcat' == 3 {
	* notation: P(y=0,x=0|z=0)=p000
	tempname n000 n100 n010 n110 ///
		n001 n101 n011 n111 ///
		n002 n102 n012 n112
	qui count if `z' == 0 & `x' == 0 & `y' == 0
	sca `n000' = r(N)
	qui count if `z' == 0 & `x' == 0 & `y' == 1
	sca `n100' = r(N)
	qui count if `z' == 0 & `x' == 1 & `y' == 0
	sca `n010' = r(N)
	qui count if `z' == 0 & `x' == 1 & `y' == 1
	sca `n110' = r(N)

	qui count if `z' == 1 & `x' == 0 & `y' == 0
	sca `n001' = r(N)
	qui count if `z' == 1 & `x' == 0 & `y' == 1
	sca `n101' = r(N)
	qui count if `z' == 1 & `x' == 1 & `y' == 0
	sca `n011' = r(N)
	qui count if `z' == 1 & `x' == 1 & `y' == 1
	sca `n111' = r(N)

	qui count if `z' == 2 & `x' == 0 & `y' == 0
	sca `n002' = r(N)
	qui count if `z' == 2 & `x' == 0 & `y' == 1
	sca `n102' = r(N)
	qui count if `z' == 2 & `x' == 1 & `y' == 0
	sca `n012' = r(N)
	qui count if `z' == 2 & `x' == 1 & `y' == 1
	sca `n112' = r(N)

	bpboundsi `n000' `n100' `n010' `n110' ///
		`n001' `n101' `n011' `n111' ///
		`n002' `n102' `n012' `n112', ///
		fmt(`fmt') 
	ret add
}
end
