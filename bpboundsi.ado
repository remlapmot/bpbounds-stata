*! 1.0.0 Tom Palmer 11apr2011
program bpboundsi, rclass
version 9.0
syntax [anything] [, fmt(string) BIVariate MATrices(namelist min=2 max=3)]

if "`fmt'" == "" {
	local fmt %5.4f
}

if "`bivariate'" == "bivariate" {
	bpboundsi_bivariate `anything', fmt(`fmt') matrices(`matrices')
}
else if "`bivariate'" == "" {
	bpboundsi_trivariate `anything', fmt(`fmt') matrices(`matrices')
}

ret add

end


program bpboundsi_bivariate, rclass
syntax [anything] [, fmt(string) MATrices(namelist min=2 max=2)]
* check type of input
if "`anything'" == "" & "`matrices'" == "" {
	di as err "No frequencies/probabilities entered as numbers or in matrices"
	error 197
}
if "`anything'" != "" & "`matrices'" != "" {
	di as err "Data input as both numbers and in matrices"
	error 197
}
if "`anything'" != "" & "`matrices'" == "" {
	local input numbers
}
else if "`anything'" == "" & "`matrices'" != "" {
	local input matrices
} 

* display data type
di _n as txt "Data:" _col(35) as res %-20s "Bivariate"

* check no. categories of z
if "`input'" == "numbers" {
	local nentered = wordcount("`anything'")
	if `nentered' != 8 & `nentered' != 12 {
		di as err "bpboundsi requires either 8 or 12 frequencies/conditional probabilities"
		error 197
	}
	local nzcats = `nentered'/4
}
else if "`input'" == "matrices" {
	tokenize `matrices'
	local zy `1'
	local zx `2'

	* check dimensions of matrices
	local rowszy = rowsof(`zy')
	local colszy = colsof(`zy')
	local rowszx = rowsof(`zx')
	local colszx = colsof(`zx')

	if `colszy' != 2 {
		di as err "ZxY matrix should have 2 columns"
		error 197
	}
	if `colszx' != 2 {
		di as err "ZxX matrix should have 2 columns"
		error 197
	}
	if `rowszy' == 2 & `rowszx' == 2 {
		local nzcats 2
	}
	else if `rowszy' == 3 & `rowszx' == 3 {
		local nzcats 3
	}
	else {
		di as err "Matrices must both have 2 or 3 rows"
		error 197
	}
}
if `nzcats' == 2 {
	di as txt "Instrument categories:" _col(35) as res %-1s "2"
}
else if `nzcats' == 3 {
	di as txt "Instrument categories:" _col(35) as res %-1s "3"
}

if `nzcats' == 2 {
	tempname ng00 ng10 ng01 ng11 nt00 nt10 nt01 nt11 ///
		g00 g10 g01 g11 t00 t10 t01 t11 ///
		ngz0 ngz1 ntz0 ntz1 ///
		gz0 gz1 tz0 tz1 ///
		inequality bplow bpupp
	if "`input'" == "numbers" {
		tokenize `anything'
		scalar `ng00' = `1'
		scalar `ng10' = `2'
		scalar `ng01' = `3'
		scalar `ng11' = `4'
		scalar `nt00' = `5'
		scalar `nt10' = `6'
		scalar `nt01' = `7'
		scalar `nt11' = `8'
	}
	else if "`input'" == "matrices" {
		scalar `ng00' = `zy'[1,1]
		scalar `ng10' = `zy'[1,2]
		scalar `ng01' = `zy'[2,1]
		scalar `ng11' = `zy'[2,2]
		scalar `nt00' = `zx'[1,1]
		scalar `nt10' = `zx'[1,2]
		scalar `nt01' = `zx'[2,1]
		scalar `nt11' = `zx'[2,2]
	}

	* check cond probs sum to 1
	sca `ngz0' = `ng00' + `ng10' 
	sca `ngz1' = `ng01' + `ng11'
	sca `ntz0' = `nt00' + `nt10'
	sca `ntz1' = `nt01' + `nt11'
	if `ng00'<=1 & `ng10'<=1 & `ng01'<=1 & `ng11'<=1 & `nt00'<=1 & `nt10'<=1 & `nt01'<=1 & `nt11'<=1 {
		if `ngz0'>1.005 | `ngz0'<.995 {
			di as err "Conditional probabilities for Z=0 do not sum to 1 in Y-Z sample"
			error 197
		}
		if `ngz1'>1.005 | `ngz1'<.995 {
			di as err "Conditional probabilities for Z=1 do not sum to 1 in Y-Z sample"
			error 197
		}
		if `ntz0'>1.005 | `ntz0'<.995 {
			di as err "Conditional probabilities for Z=0 do not sum to 1 in X-Z sample"
			error 197
		}
		if `ntz1'>1.005 | `ntz1'<.995 {
			di as err "Conditional probabilities for Z=1 do not sum to 1 in X-Z sample"
			error 197
		}
	}

	scalar `g00' = `ng00'/`ngz0'
	scalar `g10' = `ng10'/`ngz0'
	scalar `g01' = `ng01'/`ngz1'
	scalar `g11' = `ng11'/`ngz1'
	scalar `t00' = `nt00'/`ntz0'
	scalar `t10' = `nt10'/`ntz0'
	scalar `t01' = `nt01'/`ntz1'
	scalar `t11' = `nt11'/`ntz1'

	sca `gz0' = `g00' + `g10'
	sca `gz1' = `g01' + `g11'
	sca `tz0' = `t00' + `t10'
	sca `tz1' = `t01' + `t11'

	* bounds
	tempname p bplower bpupper
	matrix `p' = (`g00',`g10',`g01',`g11',`t00',`t10',`t01',`t11')'
	mata bpbounds_biv_x2y2z2()
	if `inequality' == 1 {
	ret sca inequality = `inequality'
	ret sca bplb = `bplow'
	ret sca bpub = `bpupp'
	ret mat bplower = `bplower'
	ret mat bpupper = `bpupper' 

	* bounds on probabilities
	tempname p10low1 p10low2 ///
		p10upp1 p10upp2 ///
		p11low1 p11low2 ///
		p11upp1 p11upp2 ///
		p10low p10upp p11low p11upp ///
		p10lower p10upper p11lower p11upper
	sca `p10low1' = `g11' - `t11'
	sca `p10low2' = `g10' - `t10'
	sca `p10upp1' = `g11' + `t11'
	sca `p10upp2' = `g10' + `t10'
	sca `p10low' = max(`p10low1',`p10low2')
	sca `p10upp' = min(`p10upp1',`p10upp2')
	sca `p11low1' = `g11' + `t11' - 1
	sca `p11low2' = `g10' + `t10' - 1
	sca `p11upp1' = `g11' - `t11' + 1
	sca `p11upp2' = `g10' - `t10' + 1
	sca `p11low' = max(`p11low1',`p11low2')
	sca `p11upp' = min(`p11upp1',`p11upp2')

	mat `p10lower' = (`p10low1' \ `p10low2')
	mat `p10upper' = (`p10upp1' \ `p10upp2')
	mat `p11lower' = (`p11low1' \ `p11low2')
	mat `p11upper' = (`p11upp1' \ `p11upp2')
	ret sca p10low = `p10low'
	ret sca p10upp = `p10upp'
	ret sca p11low = `p11low'
	ret sca p11upp = `p11upp'
	ret mat p10lower = `p10lower'
	ret mat p10upper = `p10upper'
	ret mat p11lower = `p11lower'
	ret mat p11upper = `p11upper'

	* bounds on causal risk ratio
	tempname rrlow rrupp
	sca `rrlow' = `p11low'/`p10upp'
	sca `rrupp' = `p11upp'/`p10low'
	ret sca crrlb = `rrlow'
	ret sca crrub = `rrupp'

	* bounds assuming monotonicity
	tempname monoinequality monolow monoupp ///
		monolow1 monolow2 monolow3 monolow4 monolow5 ///
		monoupp1 monoupp2 monoupp3 monoupp4 monoupp5 ///
		monolower monoupper
	sca `monoinequality' = `t00' - `t01' >= abs(`g00' - `g01')
	sca `monolow1' = 2*`g00' - `g01' + `t00' - 2
	sca `monolow2' = `g00' - 2*`g01' - `t01'
	sca `monolow3' = `g00' + `t00' - 2
	sca `monolow4' = -1*`g00' - `t01'
	sca `monolow5' = `g00' - `g01' + `t00' - `t01' - 1
	sca `monoupp1' = 2*`g00' - `g01' - `t00' + 1
	sca `monoupp2' = `g00' - 2*`g01' + `t01' + 1
	sca `monoupp3' = `g00' - `t00' + 1
	sca `monoupp4' = -1*`g00' + `t01' + 1
	sca `monoupp5' = `g00' - `g01' - `t00' + `t01' + 1
	sca `monolow' = max(`monolow1',`monolow2',`monolow3',`monolow4',`monolow5')
	sca `monoupp' = min(`monoupp1',`monoupp2',`monoupp3',`monoupp4',`monoupp5')
	if `monoinequality' == 1 {
		ret sca monobplb = `monolow'
		ret sca monobpub = `monoupp'
		mat `monolower' = (`monolow1' \ `monolow2' \ `monolow3' \ `monolow4' \ `monolow5')
		mat `monoupper' = (`monoupp1' \ `monoupp2' \ `monoupp3' \ `monoupp4' \ `monoupp5')
		ret mat monolower = `monolower'
		ret mat monoupper = `monoupper'
		
	* bounds on intervention probs under monotonicity
	tempname monop10low1 monop10low2 monop10upp1 monop10upp2 ///
		monop11low1 monop11low2 monop11upp1 monop11upp2 ///
		monop10lb monop10ub monop11lb monop11ub ///
		monop10lower monop10upper monop11lower monop11upper

	sca `monop10low1' = `g10' - `g11'
	sca `monop10low2' = `g10' - `t10'
	sca `monop10upp1' = 1 + `g10' - `g11'
	sca `monop10upp2' = `g10' + `t10'
	sca `monop11low1' = -`g10' + `g11'
	sca `monop11low2' = `g11' + `t11' - 1
	sca `monop11upp1' = 1 + `g11' - `t11'
	sca `monop11upp2' = 1 - `g10' + `g11'

	sca `monop10lb' = max(`monop10low1',`monop10low2')
	sca `monop10ub' = min(`monop10upp1',`monop10upp2')
	sca `monop11lb' = max(`monop11low1',`monop11low2')
	sca `monop11ub' = min(`monop11upp1',`monop11upp2')

	ret sca monop10lb = `monop10lb'
	ret sca monop10ub = `monop10ub'
	ret sca monop11lb = `monop11lb'
	ret sca monop11ub = `monop11ub'

	mat `monop10lower' = (`monop10low1' \ `monop10low2')
	mat `monop10upper' = (`monop10upp1' \ `monop10upp2')
	mat `monop11lower' = (`monop11low1' \ `monop11low2')
	mat `monop11upper' = (`monop11upp1' \ `monop11upp2')

	ret mat monop10lower = `monop10lower'
	ret mat monop10upper = `monop10upper'
	ret mat monop11lower = `monop11lower'
	ret mat monop11upper = `monop11upper'

	* bounds on causal risk ratio assuming monotonicity
	tempname monocrrlb monocrrub
	sca `monocrrlb' = `monop11lb'/`monop10ub'
	sca `monocrrub' = `monop11ub'/`monop10lb'
	ret sca monocrrlb = `monocrrlb'
	ret sca monocrrub = `monocrrub'

	}

	ret sca monoinequality = `monoinequality'

	}
	else {
		ret sca inequality = `inequality'
	}

}
else if `nzcats' == 3 {
	tempname ng00 ng10 ng01 ng11 ng02 ng12 ///
		nt00 nt10 nt01 nt11 nt02 nt12 ///
		g00 g10 g01 g11 g02 g12 ///
		t00 t10 t01 t11 t02 t12 ///
		ngz0 ngz1 ngz2 ///
		ntz0 ntz1 ntz2 ///
		gz0 gz1 gz2 ///
		tz0 tz1 tz2 ///
		inequality bplow bpupp

	if "`input'" == "numbers" {
		tokenize `anything'
		scalar `ng00' = `1'
		scalar `ng10' = `2'
		scalar `ng01' = `3'
		scalar `ng11' = `4'
		scalar `ng02' = `5'
		scalar `ng12' = `6'
		scalar `nt00' = `7'
		scalar `nt10' = `8'
		scalar `nt01' = `9'
		scalar `nt11' = `10'
		scalar `nt02' = `11'
		scalar `nt12' = `12'
	}
	else if "`input'" == "matrices" {
		scalar `ng00' = `zy'[1,1]
		scalar `ng10' = `zy'[1,2]
		scalar `ng01' = `zy'[2,1]
		scalar `ng11' = `zy'[2,2]
		scalar `ng02' = `zy'[3,1]
		scalar `ng12' = `zy'[3,2]
		scalar `nt00' = `zx'[1,1]
		scalar `nt10' = `zx'[1,2]
		scalar `nt01' = `zx'[2,1]
		scalar `nt11' = `zx'[2,2]
		scalar `nt02' = `zx'[3,1]
		scalar `nt12' = `zx'[3,2]
	}

	* check cond probs sum to 1
	sca `ngz0' = `ng00' + `ng10'
	sca `ngz1' = `ng01' + `ng11'
	sca `ngz2' = `ng02' + `ng12'
	sca `ntz0' = `nt00' + `nt10'
	sca `ntz1' = `nt01' + `nt11'
	sca `ntz2' = `nt02' + `nt12'
	if `ng00'<=1 & `ng10'<=1 & `ng01'<=1 & `ng11'<=1 & `ng02'<=1 & `ng12'<=1 & `nt00'<=1 & `nt10'<=1 & `nt01'<=1 & `nt11'<=1 & `nt02'<=1 & `nt12'<=1 {
		if `ngz0'>1.005 | `ngz0'<.995 {
			di as err "Conditional probabilities for Z=0 do not sum to 1 in Y-Z sample"
			error 197
		}
		if `ngz1'>1.005 | `ngz1'<.995 {
			di as err "Conditional probabilities for Z=1 do not sum to 1 in Y-Z sample"
			error 197
		}
		if `ngz2'>1.005 | `ngz2'<.995 {
			di as err "Conditional probabilities for Z=2 do not sum to 1 in Y-Z sample"
			error 197
		}
		if `ntz0'>1.005 | `ntz0'<.995 {
			di as err "Conditional probabilities for Z=0 do not sum to 1 in X-Z sample"
			error 197
		}
		if `ntz1'>1.005 | `ntz1'<.995 {
			di as err "Conditional probabilities for Z=1 do not sum to 1 in X-Z sample"
			error 197
		}
		if `ntz2'>1.005 | `ntz2'<.995 {
			di as err "Conditional probabilities for Z=2 do not sum to 1 in X-Z sample"
			error 197
		}
	}

	scalar `g00' = `ng00'/`ngz0'
	scalar `g10' = `ng10'/`ngz0'
	scalar `g01' = `ng01'/`ngz1'
	scalar `g11' = `ng11'/`ngz1'
	scalar `g02' = `ng02'/`ngz2'
	scalar `g12' = `ng12'/`ngz2'
	scalar `t00' = `nt00'/`ntz0'
	scalar `t10' = `nt10'/`ntz0'
	scalar `t01' = `nt01'/`ntz1'
	scalar `t11' = `nt11'/`ntz1'
	scalar `t02' = `nt02'/`ntz2'
	scalar `t12' = `nt12'/`ntz2'

	sca `gz0' = `g00' + `g10'
	sca `gz1' = `g01' + `g11'
	sca `gz2' = `g02' + `g12'
	sca `tz0' = `t00' + `t10'
	sca `tz1' = `t01' + `t11'
	sca `tz2' = `t02' + `t12'

	* bounds
	tempname p bplower bpupper
	matrix `p' = (`g00',`g10',`g01',`g11',`g02',`g12',`t00',`t10',`t01',`t11',`t02',`t12')'
	mata bpbounds_biv_x2y2z3()
	if `inequality' == 1 {
		ret sca inequality = `inequality'
		ret sca bplb = `bplow'
		ret sca bpub = `bpupp'
		ret mat bplower = `bplower'
		ret mat bpupper = `bpupper' 

		* bounds on probabilities
		tempname p10low1 p10low2 p10low3 ///
			p10upp1 p10upp2 p10upp3 ///
			p11low1 p11low2 p11low3 ///
			p11upp1 p11upp2 p11upp3 ///
			p10low p10upp p11low p11upp ///
			p10lower p10upper p11lower p11upper
		sca `p10low1' = `g10' - `t10'
		sca `p10low2' = `g11' - `t11'
		sca `p10low3' = `g12' - `t12'
		sca `p10upp1' = `g10' + `t10'
		sca `p10upp2' = `g11' + `t11'
		sca `p10upp3' = `g12' + `t12'
		sca `p10low' = max(`p10low1',`p10low2',`p10low3')
		sca `p10upp' = min(`p10upp1',`p10upp2',`p10upp3')
		sca `p11low1' = `g10' + `t10' - 1
		sca `p11low2' = `g11' + `t11' - 1
		sca `p11low3' = `g12' + `t12' - 1
		sca `p11upp1' = `g10' - `t10' + 1
		sca `p11upp2' = `g11' - `t11' + 1
		sca `p11upp3' = `g12' - `t12' + 1
		sca `p11low' = max(`p11low1',`p11low2',`p11low3')
		sca `p11upp' = min(`p11upp1',`p11upp2',`p11upp3')

		mat `p10lower' = (`p10low1' \ `p10low2' \ `p10low3')
		mat `p10upper' = (`p10upp1' \ `p10upp2' \ `p10upp3')
		mat `p11lower' = (`p11low1' \ `p11low2' \ `p11low3')
		mat `p11upper' = (`p11upp1' \ `p11upp2' \ `p11upp3')
		ret sca p10low = `p10low'
		ret sca p10upp = `p10upp'
		ret sca p11low = `p11low'
		ret sca p11upp = `p11upp'
		ret mat p10lower = `p10lower'
		ret mat p10upper = `p10upper'
		ret mat p11lower = `p11lower'
		ret mat p11upper = `p11upper'

		* bounds on causal risk ratio
		tempname rrlow rrupp
		sca `rrlow' = `p11low'/`p10upp'
		sca `rrupp' = `p11upp'/`p10low'
		ret sca crrlb = `rrlow'
		ret sca crrub = `rrupp'

		* bounds assuming monotonicity
		tempname monoinequality monolow monoupp ///
			monoin1 monoin2 monoin3 monoin4 monoin5 monoin6 ///
			monolow1 monolow2 monolow3 monolow4 monolow5 ///
			monolow6 monolow7 monolow8 monolow9 ///
			monoupp1 monoupp2 monoupp3 monoupp4 monoupp5 ///
			monoupp6 monoupp7 monoupp8 monoupp9 ///
			monolower monoupper 

		sca `monoin1' = -`g10' + `g11' - `g12'
		sca `monoin2' = -`g10' + `g11' + `t10' - `t11'
		sca `monoin3' = -`g11' + `g12' + `t11' - `t12'
		sca `monoin4' = `g11' - `g12' + `t11' - `t12'
		sca `monoin5' = `g10' - `g11' + `t10' - `t11'
		sca `monoin6' = `g10' - `g11' + `g12'
		sca `monoinequality' = (`monoin1' <= 0) & (`monoin2' <= 0) & (`monoin3' <= 0) & (`monoin4' <= 0) & (`monoin5' <= 0) & (`monoin6' <= 1)
		sca `monolow1' = -`g10' - `t10'
		sca `monolow2' = -`g10' - `g11' + `g12' - `t10'
		sca `monolow3' = -2*`g10' + `g12' - `t10'
		sca `monolow4' = -2*`g10' + `g11' - `t10'
		sca `monolow5' = -`g10' + `g12' - `t10' + `t12' - 1
		sca `monolow6' = `g12' + `t12' - 2
		sca `monolow7' = -`g10' + 2*`g12' + `t12' - 2
		sca `monolow8' = -`g11' + 2*`g12' + `t12' - 2
		sca `monolow9' = -`g10' + `g11' + `g12' + `t12' - 2
		sca `monoupp1' = 1 + `g12' - `t12'
		sca `monoupp2' = 1 - `g10' + `t10'
		sca `monoupp3' = 1 - 2*`g10' + `g11' + `t10'
		sca `monoupp4' = 1 - 2*`g10' + `g12' + `t10'
		sca `monoupp5' = 1 - `g10' + `g11' + `g12' - `t12'
		sca `monoupp6' = 1 - `g10' + `g12' + `t10' - `t12'
		sca `monoupp7' = 1 - `g10' - `g11' + `g12' + `t10'
		sca `monoupp8' = 1 - `g11' + 2*`g12' - `t12'
		sca `monoupp9' = 1 - `g10' + 2*`g12' - `t12'
		sca `monolow' = max(`monolow1',`monolow2',`monolow3',`monolow4',`monolow5',`monolow6',`monolow7',`monolow8',`monolow9')
		sca `monoupp' = min(`monoupp1',`monoupp2',`monoupp3',`monoupp4',`monoupp5',`monoupp6',`monoupp7',`monoupp8',`monoupp9')
		if `monoinequality' == 1 {
			ret sca monobplb = `monolow'
			ret sca monobpub = `monoupp'
			mat `monolower' = (`monolow1' \ `monolow2' \ `monolow3' \ `monolow4' \ `monolow5' \ `monolow6' \ `monolow7' \ `monolow8' \ `monolow9')
			mat `monoupper' = (`monoupp1' \ `monoupp2' \ `monoupp3' \ `monoupp4' \ `monoupp5' \ `monoupp6' \ `monoupp7' \ `monoupp8' \ `monoupp9')
			ret mat monolower = `monolower'
			ret mat monoupper = `monoupper'

			* bounds on intervention probabilities assuming monotonicity
			tempname monop10low1 monop10low2 monop10low3 monop10low4 ///
				monop10upp1 monop10upp2 monop10upp3 monop10upp4 ///
				monop11low1 monop11low2 monop11low3 monop11low4 ///
				monop11upp1 monop11upp2 monop11upp3 monop11upp4 ///
				monop10lb monop10ub ///
				monop11lb monop11ub ///
				monop10lower monop10upper ///
				monop11lower monop11upper

			sca `monop10low1' = `g11' - `g12'
			sca `monop10low2' = `g10' - `g11'
			sca `monop10low3' = `g10' - `g12'
			sca `monop10low4' = `g10' - `t10'
			sca `monop10upp1' = `g10' + `t10'
			sca `monop10upp2' = 1 + `g10' - `g12'
			sca `monop10upp3' = 1 + `g10' - `g11'
			sca `monop10upp4' = 1 + `g11' - `g12'
			sca `monop11low1' = -`g10' + `g12'
			sca `monop11low2' = -`g10' + `g11'
			sca `monop11low3' = -`g11' + `g12'
			sca `monop11low4' = `g12' + `t12' - 1
			sca `monop11upp1' = 1 + `g12' - `t12'
			sca `monop11upp2' = 1 - `g11' + `g12'
			sca `monop11upp3' = 1 - `g10' + `g11'
			sca `monop11upp4' = 1 - `g10' + `g12'

			sca `monop10lb' = max(`monop10low1',`monop10low2',`monop10low3',`monop10low4')
			sca `monop10ub' = min(`monop10upp1',`monop10upp2',`monop10upp3',`monop10upp4')
			sca `monop11lb' = max(`monop11low1',`monop11low2',`monop11low3',`monop11low4')
			sca `monop11ub' = min(`monop11upp1',`monop11upp2',`monop11upp3',`monop11upp4')

			ret sca monop10lb = `monop10lb'
			ret sca monop10ub = `monop10ub'
			ret sca monop11lb = `monop11lb'
			ret sca monop11ub = `monop11ub'

			mat `monop10lower' = (`monop10low1' \ `monop10low2' \ `monop10low3' \ `monop10low4')
			mat `monop10upper' = (`monop10upp1' \ `monop10upp2' \ `monop10upp3' \ `monop10upp4')
			mat `monop11lower' = (`monop11low1' \ `monop11low2' \ `monop11low3' \ `monop11low4')
			mat `monop11upper' = (`monop11upp1' \ `monop11upp2' \ `monop11upp3' \ `monop11upp4')

			ret mat monop10lower = `monop10lower'
			ret mat monop10upper = `monop10upper'
			ret mat monop11lower = `monop11lower'
			ret mat monop11upper = `monop11upper'

			* bounds on causal risk ratio assuming monotonicity
			tempname monocrrlb monocrrub
			sca `monocrrlb' = `monop11lb'/`monop10ub'
			sca `monocrrub' = `monop11ub'/`monop10lb'
			ret sca monocrrlb = `monocrrlb'
			ret sca monocrrub = `monocrrub'

		}
		ret sca monoinequality = `monoinequality'

	}
	else {
		ret sca inequality = `inequality'
	}

}

bpboundsi_display `inequality' ///
	`bplow' `bpupp' ///
	`p10low' `p10upp' ///
	`p11low' `p11upp' ///
	`rrlow' `rrupp' ///
	`monoinequality' ///
	`monolow' `monoupp' ///
	`monop10lb' `monop10ub' ///
	`monop11lb' `monop11ub' ///
	`monocrrlb' `monocrrub', fmt(`fmt')
	
end


program bpboundsi_trivariate, rclass
syntax [anything] [, fmt(string) MATrices(namelist min=2 max=3)]
* check type of input
if "`anything'" == "" & "`matrices'" == "" {
	di as err "No frequencies/probabilities entered as numbers or in matrices"
	error 197
}
if "`anything'" != "" & "`matrices'" != "" {
	di as err "Data input as both numbers and in matrices"
	error 197
}
if "`anything'" != "" & "`matrices'" == "" {
	local input numbers
}
else if "`anything'" == "" & "`matrices'" != "" {
	local input matrices
} 

* display data type
di _n as txt "Data:" _col(35) as res %-20s "Trivariate"

* check no. categories of z
if "`input'" == "numbers" {
	local nentered = wordcount("`anything'")
	if `nentered' != 8 & `nentered' != 12 {
		di as err "bpboundsi requires either 8 or 12 frequencies/conditional probabilities"
		error 197
	}
	local nzcats = `nentered'/4
}
else if "`input'" == "matrices" {
	local nzcats = wordcount("`matrices'")
}
if `nzcats' == 2 {
	di as txt "Instrument categories:" _col(35) as res %-1s "2"
}
else if `nzcats' == 3 {
	di as txt "Instrument categories:" _col(35) as res %-1s "3"
}

if `nzcats' == 2 {
	tempname inequality bplow bpupp ///
		nz0 nz1 pz0 pz1 ///
		n000 n100 n010 n110 n001 n101 n011 n111 ///
		p000 p100 p010 p110 p001 p101 p011 p111 ///
		low1 low2 low3 low4 low5 low6 low7 low8 ///
		upp1 upp2 upp3 upp4 upp5 upp6 upp7 upp8

	if "`input'" == "numbers" {	
		tokenize `anything'
		sca `n000' = `1'
		sca `n100' = `2'
		sca `n010' = `3'
		sca `n110' = `4'
		sca `n001' = `5'
		sca `n101' = `6'
		sca `n011' = `7'	
		sca `n111' = `8'
	}
	else if "`input'" == "matrices" {
		tokenize `matrices'
		local fnz0 `1'
		local fnz1 `2'

		* check matrices are 2x2
		foreach m in `1' `2' {
			local rows = rowsof(`m')
			if `rows' != 2 {
				di as err "Matrix `m' has `rows' rows"
				error 198
			}
			local cols = colsof(`m')
			if `cols' != 2 {
				di as err "Matrix `m' has `cols' columns"
				error 198
			}
		}
		sca `n000' = `fnz0'[1,1]
		sca `n100' = `fnz0'[1,2]
		sca `n010' = `fnz0'[2,1]
		sca `n110' = `fnz0'[2,2]
		sca `n001' = `fnz1'[1,1]
		sca `n101' = `fnz1'[1,2]
		sca `n011' = `fnz1'[2,1]	
		sca `n111' = `fnz1'[2,2]
	}

	* check cond probs sum to 1
	sca `nz0' = `n000' + `n100' + `n010' + `n110'
	sca `nz1' = `n001' + `n101' + `n011' + `n111'
	if `n000'<=1 & `n100'<=1 & `n010'<=1 & `n110'<=1 & `n001'<=1 & `n101'<=1 & `n011'<=1 & `n111'<=1 {
		if `nz0'>1.005 | `nz0'<.995 {
			di as err "Conditional probabilities for Z=0 do not sum to 1"
			error 197
		}
		if `nz1'>1.005 | `nz1'<.995 {
			di as err "Conditional probabilities for Z=1 do not sum to 1"
			error 197
		}
	}

	* conditional probabilities p(y,x|z)	
	sca `p000' = `n000'/`nz0'
	sca `p100' = `n100'/`nz0'
	sca `p010' = `n010'/`nz0'
	sca `p110' = `n110'/`nz0'
	sca `p001' = `n001'/`nz1'
	sca `p101' = `n101'/`nz1'
	sca `p011' = `n011'/`nz1'
	sca `p111' = `n111'/`nz1'

	sca `pz0' = `p000' + `p100' + `p010' + `p110'
	sca `pz1' = `p001' + `p101' + `p011' + `p111'

	tempname p bplower bpupper 
	matrix `p' = (`p000',`p010',`p100',`p110',`p001',`p011',`p101',`p111')'
	mata bpbounds_tri_x2y2z2()
	if `inequality' == 1 {

		ret sca inequality = `inequality'
		ret sca bplb = `bplow'
		ret sca bpub = `bpupp'
		ret mat bplower = `bplower'
		ret mat bpupper = `bpupper'

		* pearl bounds on probabilities
		tempname p10low1 p10low2 p10low3 p10low4 ///
			p10upp1 p10upp2 p10upp3 p10upp4 ///
			p11low1 p11low2 p11low3 p11low4 ///
			p11upp1 p11upp2 p11upp3 p11upp4 ///
			p10low p10upp p11low p11upp ///
			p10lower p10upper p11lower p11upper
		sca `p10low1' = `p101'
		sca `p10low2' = `p100'
		sca `p10low3' = `p100' + `p110' - `p001' - `p111'
		sca `p10low4' = `p010' + `p100' - `p001' - `p011'
		sca `p10upp1' = 1 - `p001'
		sca `p10upp2' = 1 - `p000'
		sca `p10upp3' = `p010' + `p100' + `p101' + `p111'
		sca `p10upp4' = `p100' + `p110' + `p011' + `p101'
		sca `p10low' = max(`p10low1',`p10low2',`p10low3',`p10low4')
		sca `p10upp' = min(`p10upp1',`p10upp2',`p10upp3',`p10upp4')
		sca `p11low1' = `p110'
		sca `p11low2' = `p111'
		sca `p11low3' = -`p000' - `p010' + `p001' + `p111'
		sca `p11low4' = -`p010' - `p100' + `p101' + `p111'
		sca `p11upp1' = 1 - `p011'
		sca `p11upp2' = 1 - `p010'
		sca `p11upp3' = `p000' + `p110' + `p101' + `p111'
		sca `p11upp4' = `p100' + `p110' + `p001' + `p111'
		sca `p11low' = max(`p11low1',`p11low2',`p11low3',`p11low4')
		sca `p11upp' = min(`p11upp1',`p11upp2',`p11upp3',`p11upp4')

		mat `p10lower' = (`p10low1' \ `p10low2' \ `p10low3' \ `p10low4')
		mat `p10upper' = (`p10upp1' \ `p10upp2' \ `p10upp3' \ `p10upp4')
		mat `p11lower' = (`p11low1' \ `p11low2' \ `p11low3' \ `p11low4')
		mat `p11upper' = (`p11upp1' \ `p11upp2' \ `p11upp3' \ `p11upp4')
		ret sca p10low = `p10low'
		ret sca p10upp = `p10upp'
		ret sca p11low = `p11low'
		ret sca p11upp = `p11upp'
		ret mat p10lower = `p10lower'
		ret mat p10upper = `p10upper'
		ret mat p11lower = `p11lower'
		ret mat p11upper = `p11upper'

		* bounds on causal risk ratio
		tempname rrlow rrupp
		sca `rrlow' = `p11low'/`p10upp'
		sca `rrupp' = `p11upp'/`p10low'
		ret sca crrlb = `rrlow'
		ret sca crrub = `rrupp'

		* monotonicity bounds
		tempname m1 m2 m3 m4 mlow mupp monoinequality
		sca `m1' = `p000' - `p001' >= 0
		sca `m2' = `p011' - `p010' >= 0
		sca `m3' = `p100' - `p101' >= 0
		sca `m4' = `p111' - `p110' >= 0
		sca `mlow' = `p000' - `p001' - `p011' - `p101'
		sca `mupp' = `p000' + `p010' + `p110' - `p011'
		sca `monoinequality' = (`m1'==1 & `m2'==1 & `m3'==1 & `m4'==1)
		if  `monoinequality' == 1 {
			ret sca monobplb = `mlow'
			ret sca monobpub = `mupp'
			
			* bounds on intervention probabilities assuming monotonicity
			tempname monop10low monop10upp monop11low monop11upp
			sca `monop10low' = `p100'
			sca `monop10upp' = 1 - `p000'
			sca `monop11low' = `p111'
			sca `monop11upp' = 1 - `p011'

			ret sca monop10low = `monop10low'
			ret sca monop10upp = `monop10upp'
			ret sca monop11low = `monop11low'
			ret sca monop11upp = `monop11upp'

			* bounds on causal risk ratio assuming monotonicity
			tempname monocrrlow monocrrupp
			sca `monocrrlow' = `monop11low'/`monop10upp'
			sca `monocrrupp' = `monop11upp'/`monop10low'
			ret sca monocrrlb = `monocrrlow'
			ret sca monocrrub = `monocrrupp'	
				
		}
		ret sca monoinequality = `monoinequality'
	}
	else {
		ret sca inequality = `inequality'
	}
}
else if `nzcats' == 3 {
	tempname inequality bplow bpupp ///
		nz0 nz1 nz2 pz0 pz1 pz2 ///
		n000 n100 n010 n110 n001 n101 n011 n111 n002 n102 n012 n112 ///
		p000 p100 p010 p110 p001 p101 p011 p111 p002 p102 p012 p112 ///
		low1 low2 low3 low4 low5 low6 low7 low8 low9 low10 low11 low12 ///
		upp1 upp2 upp3 upp4 upp5 upp6 upp7 upp8 upp9 upp10 upp11 upp12

	if "`input'" == "numbers" {		
		tokenize `anything'
		sca `n000' = `1'
		sca `n100' = `2'
		sca `n010' = `3'
		sca `n110' = `4'
		sca `n001' = `5'
		sca `n101' = `6'
		sca `n011' = `7'	
		sca `n111' = `8'
		sca `n002' = `9'
		sca `n102' = `10'
		sca `n012' = `11'
		sca `n112' = `12'
	}
	else if "`input'" == "matrices" {
		tokenize `matrices'
		local fnz0 `1'
		local fnz1 `2'
		local fnz2 `3'

		* check matrices are 2x2
		foreach m in `1' `2' `3' {
			local rows = rowsof(`m')
			if `rows' != 2 {
				di as err "Matrix `m' has `rows' rows"
				error 198
			}	
			local cols = colsof(`m')
			if `cols' != 2 {
				di as err "Matrix `m' has `cols' columns"
				error 198
			}
		}
		sca `n000' = `fnz0'[1,1]
		sca `n100' = `fnz0'[1,2]
		sca `n010' = `fnz0'[2,1]
		sca `n110' = `fnz0'[2,2]
		sca `n001' = `fnz1'[1,1]
		sca `n101' = `fnz1'[1,2]
		sca `n011' = `fnz1'[2,1]	
		sca `n111' = `fnz1'[2,2]
		sca `n002' = `fnz2'[1,1]
		sca `n102' = `fnz2'[1,2]
		sca `n012' = `fnz2'[2,1]	
		sca `n112' = `fnz2'[2,2]
	}

	* check cond probs sum to 1
	sca `nz0' = `n000' + `n100' + `n010' + `n110'
	sca `nz1' = `n001' + `n101' + `n011' + `n111'
	sca `nz2' = `n002' + `n102' + `n012' + `n112'

	if `n000'<=1 & `n100'<=1 & `n010'<=1 & `n110'<=1 & `n001'<=1 & `n101'<=1 & `n011'<=1 & `n111'<=1 & `n002'<=1 & `n102'<=1 & `n012'<=1 & `n112'<=1 {
		if `nz0'>1.005 | `nz0'<.995 {
			di as err "Conditional probabilities for Z=0 do not sum to 1"
			error 197
		}
		if `nz1'>1.005 | `nz1'<.995 {
			di as err "Conditional probabilities for Z=1 do not sum to 1"
			error 197
		}
		if `nz2'>1.005 | `nz2'<.995 {
			di as err "Conditional probabilities for Z=1 do not sum to 2"
			error 197
		}
	}

	* conditional probabilities p(y,x|z)	
	sca `p000' = `n000'/`nz0'
	sca `p100' = `n100'/`nz0'
	sca `p010' = `n010'/`nz0'
	sca `p110' = `n110'/`nz0'
	sca `p001' = `n001'/`nz1'
	sca `p101' = `n101'/`nz1'
	sca `p011' = `n011'/`nz1'
	sca `p111' = `n111'/`nz1'
	sca `p002' = `n002'/`nz2'
	sca `p102' = `n102'/`nz2'
	sca `p012' = `n012'/`nz2'
	sca `p112' = `n112'/`nz2'

	sca `pz0' = `p000' + `p100' + `p010' + `p110'
	sca `pz1' = `p001' + `p101' + `p011' + `p111'
	sca `pz2' = `p002' + `p102' + `p012' + `p112'

	tempname p bplower bpupper
	matrix `p' = (`p000',`p100',`p010',`p110',`p001',`p101',`p011',`p111',`p002',`p102',`p012',`p112')'
	mata bpbounds_tri_x2y2z3()
	if `inequality' == 1 {
		ret sca inequality = `inequality'
		ret sca bplb = `bplow'
		ret sca bpub = `bpupp'
		ret mat bplower = `bplower'
		ret mat bpupper = `bpupper'

		* bounds on probabilities
		tempname p10low1 p10low2 p10low3 p10low4 ///
			p10low5 p10low6 p10low7 p10low8 p10low9 ///
			p10upp1 p10upp2 p10upp3 p10upp4 ///
			p10upp5 p10upp6 p10upp7 p10upp8 p10upp9 ///
			p11low1 p11low2 p11low3 p11low4 ///
			p11low5 p11low6 p11low7 p11low8 p11low9 ///
			p11upp1 p11upp2 p11upp3 p11upp4 ///
			p11upp5 p11upp6 p11upp7 p11upp8 p11upp9 ///
			p10low p10upp p11low p11upp ///
			p10lower p10upper p11lower p11upper
		sca `p10low1' = `p100'
		sca `p10low2' = `p101'
		sca `p10low3' = `p102'
		sca `p10low4' = `p100' + `p110' + `p101' + `p011' - 1
		sca `p10low5' = `p100' + `p010' + `p101' + `p111' - 1
		sca `p10low6' = `p101' + `p111' + `p102' + `p012' - 1
		sca `p10low7' = `p101' + `p011' + `p102' + `p112' - 1      
		sca `p10low8' = `p102' + `p112' + `p100' + `p010' - 1
		sca `p10low9' = `p102' + `p012' + `p100' + `p110' - 1 
		sca `p10upp1' = 1 - `p000'
		sca `p10upp2' = 1 - `p001'
		sca `p10upp3' = 1 - `p002'
		sca `p10upp4' = `p100' + `p010' + `p101' + `p111'
		sca `p10upp5' = `p100' + `p110' + `p101' + `p011'
		sca `p10upp6' = `p101' + `p011' + `p102' + `p112'
		sca `p10upp7' = `p101' + `p111' + `p102' + `p012'
		sca `p10upp8' = `p102' + `p012' + `p100' + `p110'
		sca `p10upp9' = `p102' + `p112' + `p100' + `p010'
		sca `p10low' = max(`p10low1',`p10low2',`p10low3',`p10low4',`p10low5',`p10low6',`p10low7',`p10low8',`p10low9')
		sca `p10upp' = min(`p10upp1',`p10upp2',`p10upp3',`p10upp4',`p10upp5',`p10upp6',`p10upp7',`p10upp8',`p10upp9')
		sca `p11low1' = `p110'
		sca `p11low2' = `p111'
		sca `p11low3' = `p112'
		sca `p11low4' = `p100' + `p110' - `p101' - `p011'
		sca `p11low5' = -`p100' - `p010' + `p101' + `p111'
		sca `p11low6' = `p101' + `p111' - `p102' - `p012'
		sca `p11low7' = -`p101' - `p011' + `p102' + `p112'
		sca `p11low8' = `p102' + `p112' - `p100' -`p010'
		sca `p11low9' = -`p102' - `p012' + `p100' + `p110'
		sca `p11upp1' = 1 - `p010'
		sca `p11upp2' = 1 - `p011'
		sca `p11upp3' = 1 - `p012'
		sca `p11upp4' = `p100' + `p110' - `p101' - `p011' + 1
		sca `p11upp5' = -`p100' - `p010' + `p101' + `p111' + 1
		sca `p11upp6' = `p101' + `p111' - `p102' - `p012' + 1
		sca `p11upp7' = -`p101' - `p011' + `p102' + `p112' + 1
		sca `p11upp8' = `p102' + `p112' - `p100' - `p010' + 1
		sca `p11upp9' = -`p102' - `p012' + `p100' + `p110' + 1

		sca `p11low' = max(`p11low1',`p11low2',`p11low3',`p11low4',`p11low5',`p11low6',`p11low7',`p11low8',`p11low9')
		sca `p11upp' = min(`p11upp1',`p11upp2',`p11upp3',`p11upp4',`p11upp5',`p11upp6',`p11upp7',`p11upp8',`p11upp9')

		mat `p10lower' = (`p10low1' \ `p10low2' \ `p10low3' \ `p10low4' \ `p10low5' \ `p10low6' \ `p10low7' \ `p10low8' \ `p10low9')
		mat `p10upper' = (`p10upp1' \ `p10upp2' \ `p10upp3' \ `p10upp4' \ `p10upp5' \ `p10upp6' \ `p10upp7' \ `p10upp8' \ `p10upp9')
		mat `p11lower' = (`p11low1' \ `p11low2' \ `p11low3' \ `p11low4' \ `p11low5' \ `p11low6' \ `p11low7' \ `p11low8' \ `p11low9')
		mat `p11upper' = (`p11upp1' \ `p11upp2' \ `p11upp3' \ `p11upp4' \ `p11upp5' \ `p11upp6' \ `p11upp7' \ `p11upp8' \ `p11upp9')
		ret sca p10low = `p10low'
		ret sca p10upp = `p10upp'
		ret sca p11low = `p11low'
		ret sca p11upp = `p11upp'
		ret mat p10lower = `p10lower'
		ret mat p10upper = `p10upper'
		ret mat p11lower = `p11lower'
		ret mat p11upper = `p11upper'

		* bounds on causal risk ratio
		tempname rrlow rrupp
		sca `rrlow' = `p11low'/`p10upp'
		sca `rrupp' = `p11upp'/`p10low'
		ret sca crrlb = `rrlow'
		ret sca crrub = `rrupp'

		* monotonicity bounds
		tempname m1 m2 m3 m4 mlow mupp monoinequality
		sca `m1' = (`p102' <= `p101') & (`p101' <= `p100')
		sca `m2' = (`p110' <= `p111') & (`p111' <= `p112')
		sca `m3' = (`p010' <= `p011') & (`p011' <= `p012')
		sca `m4' = (`p002' <= `p001') & (`p001' <= `p000')
		sca `monoinequality' = (`m1'==1 & `m2'==1 & `m3'==1 & `m4'==1)
		if  `monoinequality' == 1 {
			sca `mlow' = `p112' + `p000' - 1
			sca `mupp' = 1 - `p100' - `p110'
				ret sca monobplb = `mlow'
				ret sca monobpub = `mupp'
				
			* bounds on intervention probabilities assuming monotonicity
			tempname monop10low monop10upp monop11low monop11upp
			sca `monop10low' = `p100'
			sca `monop10upp' = 1 - `p000'
			sca `monop11low' = `p112'
			sca `monop11upp' = 1 - `p012'

			ret sca monop10low = `monop10low'
			ret sca monop10upp = `monop10upp'
			ret sca monop11low = `monop11low'
			ret sca monop11upp = `monop11upp'

			* bounds on causal risk ratio assuming monotonicity
			tempname monocrrlow monocrrupp
			sca `monocrrlow' = `monop11low'/`monop10upp'
			sca `monocrrupp' = `monop11upp'/`monop10low'
			ret sca monocrrlb = `monocrrlow'
			ret sca monocrrub = `monocrrupp'	

		}
		ret sca monoinequality = `monoinequality'

	}
	else {
		ret sca inequality = `inequality'
	}

}

bpboundsi_display `inequality' ///
	`bplow' `bpupp' ///
	`p10low' `p10upp' ///
	`p11low' `p11upp' ///
	`rrlow' `rrupp' ///
	`monoinequality' ///
	`mlow' `mupp' ///
	`monop10low' `monop10upp' ///
	`monop11low' `monop11upp' ///
	`monocrrlow' `monocrrupp', fmt(`fmt')
	
end


program bpboundsi_display
syntax anything , fmt(string)

tokenize `anything'
local ivinequality `1'
local acelb `2'
local aceub `3'
local px0lb `4'
local px0ub `5'
local px1lb `6'
local px1ub `7'
local crrlb `8'
local crrub `9'
local monoinequality `10'
local macelb `11'
local maceub `12'
local mpx0lb `13'
local mpx0ub `14'
local mpx1lb `15'
local mpx1ub `16'
local mcrrlb `17'
local mcrrub `18'

di _n _d(29) as txt "{c -}" "{c TT}" _d(48) "{c -}"
di as txt _col(30) "{c |}" _col(60) "Bounds"
di as txt %28s "Causal parameter" _col(30) "{c |}" _col(55) "Lower" _col(65) "Upper" 
di _d(29) as txt "{c -}" "{c +}" _d(48) "{c -}"
di as txt %28s "IV inequality constraints" _col(30) "{c |}" _c
if `ivinequality' == 0 {
	di _col(35) as err "not satisfied"
}
else {
	di as res _col(35) "satisfied" 
	di as txt %28s "ACE" _col(30) "{c |}" _col(55) as res `fmt' `acelb' _col(65) `fmt' `aceub'
	di as txt %28s "P(Y|do(X=0))" _col(30) "{c |}" _col(55) as res `fmt' `px0lb' _col(65) `fmt' `px0ub'
	di as txt %28s "P(Y|do(X=1))" _col(30) "{c |}" _col(55) as res `fmt' `px1lb' _col(65) `fmt' `px1ub'
	di as txt %28s "CRR" _col(30) "{c |}" _col(55) as res `fmt' `crrlb' _col(65) `fmt' `crrub'
	di as txt _d(29) "{c -}" "{c +}" _d(48) "{c -}"
	di as txt %~28s "Assuming monotonicity:" _col(30) "{c |}"
	di as txt %28s "Monotonicity constraints" _col(30) "{c |}" _c
	if `monoinequality' == 0 {
		di _col(35) as err "not satisfied"
	}
	else {
		di as res _col(35) "satisfied"
		di as txt %28s "ACE" _col(30) "{c |}" _col(55) as res `fmt' `macelb' _col(65) `fmt' `maceub'
		di as txt %28s "P(Y|do(X=0))" _col(30) "{c |}" _col(55) as res `fmt' `mpx0lb' _col(65) `fmt' `mpx0ub'
		di as txt %28s "P(Y|do(X=1))" _col(30) "{c |}" _col(55) as res `fmt' `mpx1lb' _col(65) `fmt' `mpx1ub'
		di as txt %28s "CRR" _col(30) "{c |}" _col(55) as res `fmt' `mcrrlb' _col(65) `fmt' `mcrrub'
	}
}
di _d(29) as txt "{c -}" "{c BT}" _d(48) "{c -}"
end


mata

void function bpbounds_biv_x2y2z2(){

A1 = (1,3,1,0,-2,0,0,0 \ 
1,2,0,0,-1,0,0,0 \ 
2,2,-1,0,0,0,-1,0 \ 
4,3,-2,0,0,0,-2,0 \ 
0,0,0,0,1,0,0,0 \ 
2,1,-1,0,1,0,-1,0 \ 
-1,1,1,0,2,0,0,0 \ 
1,0,0,0,1,0,0,0 \ 
0,0,1,0,0,0,1,0 \ 
-1,0,2,0,0,0,2,0 \ 
2,0,-1,0,2,0,0,0 \ 
1,0,0,0,0,0,0,0 \ 
0,0,1,0,0,0,0,0 \ 
1,0,-1,0,1,0,1,0 \ 
-1,0,1,0,1,0,1,0 )

A2 = (2,1,-2,0,0,0,2,0 \ 
0,0,0,0,0,0,1,0 \ 
0,1,1,0,-1,0,1,0 \ 
4,2,-1,0,-2,0,0,0 \ 
1,2,2,0,0,0,-2,0 \ 
2,1,-1,0,-1,0,1,0 \ 
1,1,-1,0,0,0,1,0 \ 
2,1,0,0,-1,0,0,0 \ 
1,1,1,0,0,0,-1,0 \ 
0,1,0,0,1,0,0,0 \ 
0,1,1,0,1,0,-1,0 \ 
1,2,1,0,-1,0,-1,0 \ 
3,2,-1,0,-1,0,-1,0 \ 
1,1,0,0,0,0,-1,0 \ 
1,1,0,0,-1,0,0,0 \ 
1,1,-1,0,0,0,0,0 \ 
0,1,0,0,0,0,0,0)

A = J(32,8,.)
A[1..15,] = A1
A[16..32,] = A2

ice = (1, 1, 1, 1, 0, 1, -1, 1, 1, 1, 1, 0, 0, 0, 0, -1, 0, 1, -1, -1,
 -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0)'

p = st_matrix(st_local("p"))

prod = A*p
ivinequality = select(prod, ice:==0)
low = -1*select(prod, ice:==1)
upp = select(prod, ice:==-1)
inequality = min(ivinequality) >= 0
bplow = max(low)
bpupp = min(upp)
st_numscalar(st_local("inequality"), inequality)
st_numscalar(st_local("bplow"), bplow)
st_numscalar(st_local("bpupp"), bpupp)
st_matrix(st_local("bplower"), low)
st_matrix(st_local("bpupper"), upp)

} 


void function bpbounds_biv_x2y2z3(){

A1 = (0,-1,0,0,0,0,0,-1,0,0,0,0 \ 
0,0,0,-1,0,0,0,0,0,-1,0,0 \ 
0,0,0,0,0,-1,0,0,0,0,0,-1 \ 
0,-1,0,0,0,1,0,-1,0,0,0,-1 \ 
0,-1,0,1,0,0,0,-1,0,-1,0,0 \ 
0,0,0,-1,0,1,0,0,0,-1,0,-1 \ 
0,0,0,1,0,-1,0,0,0,-1,0,-1 \ 
0,1,0,-1,0,0,0,-1,0,-1,0,0 \ 
0,1,0,0,0,-1,0,-1,0,0,0,-1 \ 
0,-2,0,0,0,1,0,-2,0,0,0,0 \ 
0,-2,0,1,0,0,0,-2,0,0,0,0 \ 
0,0,0,-2,0,1,0,0,0,-2,0,0 \ 
0,0,0,1,0,-2,0,0,0,0,0,-2 \ 
0,1,0,-2,0,0,0,0,0,-2,0,0 \ 
0,1,0,0,0,-2,0,0,0,0,0,-2)

A2 = (0,-1,0,0,0,0,0,1,0,0,0,0 \ 
0,0,0,-1,0,0,0,0,0,1,0,0 \ 
0,0,0,0,0,-1,0,0,0,0,0,1 \ 
0,0,0,0,0,1,0,0,0,0,0,-1 \ 
0,0,0,1,0,0,0,0,0,-1,0,0 \ 
0,1,0,0,0,0,0,-1,0,0,0,0 \ 
0,-1,0,0,0,1,0,1,0,0,0,-1 \ 
0,-1,0,1,0,0,0,1,0,-1,0,0 \ 
0,0,0,-1,0,1,0,0,0,1,0,-1 \ 
0,0,0,1,0,-1,0,0,0,-1,0,1 \ 
0,1,0,-1,0,0,0,-1,0,1,0,0 \ 
0,1,0,0,0,-1,0,-1,0,0,0,1 \ 
0,-1,0,0,0,1,0,-1,0,0,0,1 \ 
0,-1,0,1,0,0,0,-1,0,1,0,0 \ 
0,0,0,-1,0,1,0,0,0,-1,0,1) 

A3 = (0,0,0,1,0,-1,0,0,0,1,0,-1 \ 
0,1,0,-1,0,0,0,1,0,-1,0,0 \ 
0,1,0,0,0,-1,0,1,0,0,0,-1 \ 
0,-1,0,0,0,2,0,0,0,0,0,-2 \ 
0,-1,0,2,0,0,0,0,0,-2,0,0 \ 
0,0,0,-1,0,2,0,0,0,0,0,-2 \ 
0,0,0,2,0,-1,0,0,0,-2,0,0 \ 
0,2,0,-1,0,0,0,-2,0,0,0,0 \ 
0,2,0,0,0,-1,0,-2,0,0,0,0 \ 
0,0,0,0,0,1,0,0,0,0,0,1 \ 
0,0,0,1,0,0,0,0,0,1,0,0 \ 
0,1,0,0,0,0,0,1,0,0,0,0 \ 
0,-1,0,0,0,1,0,1,0,0,0,1 \ 
0,-1,0,1,0,0,0,1,0,1,0,0 \ 
0,0,0,-1,0,1,0,0,0,1,0,1)

A4 = (0,0,0,1,0,-1,0,0,0,1,0,1 \ 
0,1,0,-1,0,0,0,1,0,1,0,0 \ 
0,1,0,0,0,-1,0,1,0,0,0,1 \ 
0,-2,0,0,0,1,0,2,0,0,0,0 \ 
0,-2,0,1,0,0,0,2,0,0,0,0 \ 
0,0,0,-2,0,1,0,0,0,2,0,0 \ 
0,0,0,1,0,-2,0,0,0,0,0,2 \ 
0,1,0,-2,0,0,0,0,0,2,0,0 \ 
0,1,0,0,0,-2,0,0,0,0,0,2 \ 
0,-1,0,0,0,2,0,0,0,0,0,2 \ 
0,-1,0,2,0,0,0,0,0,2,0,0 \ 
0,0,0,-1,0,2,0,0,0,0,0,2 \ 
0,0,0,2,0,-1,0,0,0,2,0,0 \ 
0,2,0,-1,0,0,0,2,0,0,0,0 \ 
0,2,0,0,0,-1,0,2,0,0,0,0)

A = J(60,12,.)
A[1..15,] = A1
A[16..30,] = A2
A[31..45,] = A3
A[46..60,] = A4

alpha = (-1, -1, -1, 0, 0, 0, 0, 0, 0, 
	-1, -1, -1, -1, -1, -1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 1, -1, 
	-1, -1, -1, -1, -1, 1, 1, 1, 1, 
	1, 1, -1, -1, -1, 0, 0, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1, -1)'

cons = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, -1, -1, -1, -1, -1, 
	-1, -1, -1, -1, -1, -1, -1, -1, -1, 
	-1, -1, -1, -1, -1, -1, -1, -1, -1, 
	-1, -2, -2, -2, -2, -2, -2, -2, -2, 
	-2, -2, -2, -2, -2, -2, -2, -3, -3, -3, -3, -3, -3)'

p = st_matrix(st_local("p"))

prod = A*p + cons
ivinequality = select(prod, alpha:==0)
low = select(prod, alpha:==-1)
upp = -1*select(prod, alpha:==1)
inequality = max(ivinequality) <= 0
bplow = max(low)
bpupp = min(upp)
st_numscalar(st_local("inequality"), inequality)
st_numscalar(st_local("bplow"), bplow)
st_numscalar(st_local("bpupp"), bpupp)
st_matrix(st_local("bplower"), low)
st_matrix(st_local("bpupper"), upp)

} 


void function bpbounds_tri_x2y2z2(){
A = (-1,0,0,0,1,1,1,0 \ 
0,1,1,0,0,0,0,0 \ 
1,2,2,0,-1,-1,0,0 \ 
-1,1,1,0,1,1,0,0 \ 
1,1,1,0,-1,0,0,0 \ 
0,0,0,0,0,1,1,0 \ 
-1,-1,0,0,1,2,2,0 \ 
1,1,0,0,-1,1,1,0 \ 
1,0,0,0,0,0,0,0 \ 
0,-1,0,0,1,1,1,0 \ 
1,-1,0,1,1,1,0,0 \ 
2,2,1,1,0,-2,-1,0 \ 
1,1,1,0,0,-1,0,0 \ 
0,0,0,0,1,0,0,0 \ 
2,1,0,2,-1,-1,0,0 \ 
1,1,2,2,0,-1,-2,0 \ 
1,1,0,1,0,-1,0,0 \ 
1,1,1,1,0,-1,-1,0 \ 
1,0,0,1,0,0,0,0 \ 
1,0,1,1,0,0,-1,0 \ 
1,1,0,1,-1,0,0,0 \ 
0,1,1,1,0,0,-1,0 \ 
0,0,0,0,0,1,0,0 \ 
1,1,1,1,-1,-1,-1,0 \ 
0,1,0,0,0,0,0,0 \ 
0,0,0,1,0,0,0,0 \ 
0,0,0,0,0,0,1,0 \ 
0,0,1,0,0,0,0,0)

ice = (1, 1, 1, 1, 1, 1, 1, 1, 0, 0, -1, -1, 0, 0, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0)'

p = st_matrix(st_local("p"))

prod = A*p
ivinequality = select(prod, ice:==0)
low = -1*select(prod, ice:==1)
upp = select(prod, ice:==-1)
inequality = min(ivinequality) >= 0
bplow = max(low)
bpupp = min(upp)
st_numscalar(st_local("inequality"), inequality)
st_numscalar(st_local("bplow"), bplow)
st_numscalar(st_local("bpupp"), bpupp)
st_matrix(st_local("bplower"), low)
st_matrix(st_local("bpupper"), upp)

}


void function bpbounds_tri_x2y2z3(){

A1 = (0,-1,-1,0,0,0,0,0,0,0,0,0 \ 
0,0,0,0,0,-1,-1,0,0,0,0,0 \ 
0,0,0,0,0,0,0,0,0,-1,-1,0 \ 
0,-1,-1,-1,0,0,0,0,0,1,0,0 \ 
0,-1,-1,-1,0,1,0,0,0,0,0,0 \ 
0,0,0,0,0,-1,-1,-1,0,1,0,0 \ 
0,0,0,0,0,1,0,0,0,-1,-1,-1 \ 
0,1,0,0,0,-1,-1,-1,0,0,0,0 \ 
0,1,0,0,0,0,0,0,0,-1,-1,-1 \ 
0,-1,-1,-1,0,0,0,0,0,0,0,1 \ 
0,-1,-1,-1,0,0,0,1,0,0,0,0 \ 
0,-1,-1,0,0,-1,0,-1,0,1,0,0 \ 
0,-1,-1,0,0,1,0,0,0,-1,0,-1 \ 
0,-1,0,-1,0,-1,-1,0,0,1,0,0 \
0,-1,0,-1,0,1,0,0,0,-1,-1,0)

A2 = (0,0,0,0,0,-1,-1,-1,0,0,0,1 \ 
0,0,0,0,0,0,0,1,0,-1,-1,-1 \ 
0,0,0,1,0,-1,-1,-1,0,0,0,0 \ 
0,0,0,1,0,0,0,0,0,-1,-1,-1 \ 
0,1,0,0,0,-1,-1,0,0,-1,0,-1 \ 
0,1,0,0,0,-1,0,-1,0,-1,-1,0 \ 
0,-1,-1,0,0,-1,0,-1,0,0,0,1 \ 
0,-1,-1,0,0,0,0,1,0,-1,0,-1 \ 
0,-1,-1,1,0,-1,0,-1,0,0,0,0 \ 
0,-1,-1,1,0,0,0,0,0,-1,0,-1 \
0,-1,0,-1,0,-1,-1,0,0,0,0,1 \ 
0,-1,0,-1,0,-1,-1,1,0,0,0,0 \ 
0,-1,0,-1,0,0,0,0,0,-1,-1,1 \ 
0,-1,0,-1,0,0,0,1,0,-1,-1,0 \ 
0,0,0,0,0,-1,-1,1,0,-1,0,-1) 

A3 = (0,0,0,0,0,-1,0,-1,0,-1,-1,1 \ 
0,0,0,1,0,-1,-1,0,0,-1,0,-1 \ 
0,0,0,1,0,-1,0,-1,0,-1,-1,0 \ 
0,-1,-1,-1,0,-1,-1,0,0,1,0,1 \ 
0,-1,-1,-1,0,1,0,1,0,-1,-1,0 \ 
0,-1,-1,0,0,-1,-1,-1,0,1,0,1 \ 
0,-1,-1,0,0,1,0,1,0,-1,-1,-1 \ 
0,1,0,1,0,-1,-1,-1,0,-1,-1,0 \ 
0,1,0,1,0,-1,-1,0,0,-1,-1,-1 \ 
0,-2,-2,-1,0,0,0,0,0,1,0,1 \ 
0,-2,-2,-1,0,1,0,1,0,0,0,0 \ 
0,0,0,0,0,-2,-2,-1,0,1,0,1 \ 
0,0,0,0,0,1,0,1,0,-2,-2,-1 \ 
0,1,0,1,0,-2,-2,-1,0,0,0,0 \ 
0,1,0,1,0,0,0,0,0,-2,-2,-1) 

A4 = (0,-2,-2,0,0,-1,0,-1,0,1,0,1 \ 
0,-2,-2,0,0,1,0,1,0,-1,0,-1 \ 
0,-1,0,-1,0,-2,-2,0,0,1,0,1 \ 
0,-1,0,-1,0,1,0,1,0,-2,-2,0 \ 
0,1,0,1,0,-2,-2,0,0,-1,0,-1 \
0,1,0,1,0,-1,0,-1,0,-2,-2,0 \ 
0,0,0,0,0,0,0,1,0,0,1,0 \ 
0,0,0,0,0,0,1,0,0,0,0,1 \ 
0,0,0,1,0,0,0,0,0,0,1,0 \ 
0,0,0,1,0,0,1,0,0,0,0,0 \ 
0,0,1,0,0,0,0,0,0,0,0,1 \ 
0,0,1,0,0,0,0,1,0,0,0,0 \ 
0,0,0,0,0,0,0,0,0,1,1,0 \ 
0,0,0,0,0,0,0,0,0,1,1,1 \ 
0,0,0,0,0,0,1,0,0,1,0,0)

A5 = (0,0,0,0,0,1,0,0,0,0,1,0 \ 
0,0,0,0,0,1,1,0,0,0,0,0 \ 
0,0,0,0,0,1,1,1,0,0,0,0 \ 
0,0,1,0,0,0,0,0,0,1,0,0 \ 
0,0,1,0,0,1,0,0,0,0,0,0 \ 
0,1,0,0,0,0,0,0,0,0,1,0 \ 
0,1,0,0,0,0,1,0,0,0,0,0 \ 
0,1,1,0,0,0,0,0,0,0,0,0 \ 
0,1,1,1,0,0,0,0,0,0,0,0 \ 
0,-1,0,-1,0,0,0,0,0,2,1,0 \ 
0,-1,0,-1,0,2,1,0,0,0,0,0 \ 
0,0,0,0,0,-1,0,-1,0,2,1,0 \ 
0,0,0,0,0,2,1,0,0,-1,0,-1 \ 
0,2,1,0,0,-1,0,-1,0,0,0,0 \ 
0,2,1,0,0,0,0,0,0,-1,0,-1) 

A6 = (0,-1,-1,0,0,0,1,0,0,1,0,1 \ 
0,-1,-1,0,0,1,0,1,0,0,1,0 \ 
0,-1,0,-1,0,0,0,1,0,1,1,0 \ 
0,-1,0,-1,0,1,1,0,0,0,0,1 \ 
0,0,0,1,0,-1,0,-1,0,1,1,0 \ 
0,0,0,1,0,1,1,0,0,-1,0,-1 \ 
0,0,1,0,0,-1,-1,0,0,1,0,1 \ 
0,0,1,0,0,1,0,1,0,-1,-1,0 \ 
0,1,0,1,0,-1,-1,0,0,0,1,0 \ 
0,1,0,1,0,0,1,0,0,-1,-1,0 \ 
0,1,1,0,0,-1,0,-1,0,0,0,1 \ 
0,1,1,0,0,0,0,1,0,-1,0,-1 \ 
0,-1,0,-1,0,1,0,0,0,1,1,0 \ 
0,-1,0,-1,0,1,1,0,0,1,0,0 \ 
0,1,0,0,0,-1,0,-1,0,1,1,0) 

A7 = (0,1,0,0,0,1,1,0,0,-1,0,-1 \ 
0,1,1,0,0,-1,0,-1,0,1,0,0 \ 
0,1,1,0,0,1,0,0,0,-1,0,-1 \ 
0,-1,-1,-1,0,1,0,1,0,1,1,0 \ 
0,-1,-1,-1,0,1,1,0,0,1,0,1 \ 
0,1,0,1,0,-1,-1,-1,0,1,1,0 \ 
0,1,0,1,0,1,1,0,0,-1,-1,-1 \ 
0,1,1,0,0,-1,-1,-1,0,1,0,1 \ 
0,1,1,0,0,1,0,1,0,-1,-1,-1 \ 
0,0,0,0,0,1,0,1,0,1,2,0 \ 
0,0,0,0,0,1,2,0,0,1,0,1 \ 
0,1,0,1,0,0,0,0,0,1,2,0 \ 
0,1,0,1,0,1,2,0,0,0,0,0 \ 
0,1,2,0,0,0,0,0,0,1,0,1 \ 
0,1,2,0,0,1,0,1,0,0,0,0) 

A8 = (0,0,1,0,0,1,0,1,0,1,1,0 \ 
0,0,1,0,0,1,1,0,0,1,0,1 \ 
0,1,0,1,0,0,1,0,0,1,1,0 \ 
0,1,0,1,0,1,1,0,0,0,1,0 \ 
0,1,1,0,0,0,1,0,0,1,0,1 \ 
0,1,1,0,0,1,0,1,0,0,1,0 \ 
0,-1,0,-1,0,1,0,1,0,2,2,0 \ 
0,-1,0,-1,0,2,2,0,0,1,0,1 \ 
0,1,0,1,0,-1,0,-1,0,2,2,0 \ 
0,1,0,1,0,2,2,0,0,-1,0,-1 \ 
0,2,2,0,0,-1,0,-1,0,1,0,1 \ 
0,2,2,0,0,1,0,1,0,-1,0,-1)

A = J(117,12,.)
A[1..15,] = A1
A[16..30,] = A2
A[31..45,] = A3
A[46..60,] = A4
A[61..75,] = A5
A[76..90,] = A6
A[91..105,] = A7
A[106..117,] = A8

ice = (-1, -1, -1, 0, 0, 0, 0, 0, 0, -1, -1, 0, 0, 0, 0,
	-1, -1, -1, -1, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
	-1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 1, 0, 
	1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 
	0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1)'

cons = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
	-1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 
	-2, -2, -2, -2, -2, -2, -2, -2)'

p = st_matrix(st_local("p"))	
	
prod = A*p
prod = prod + cons
ivinequality = select(prod, ice:==0)
low = select(prod, ice:==-1)
upp = -1*select(prod, ice:==1)
inequality = max(ivinequality) <= 0
bplow = max(low)
bpupp = min(upp)
st_numscalar(st_local("inequality"), inequality)
st_numscalar(st_local("bplow"), bplow)
st_numscalar(st_local("bpupp"), bpupp)
st_matrix(st_local("bplower"), low)
st_matrix(st_local("bpupper"), upp)

}

end
