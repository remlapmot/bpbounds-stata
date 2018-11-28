{smcl}
{* *! version 1.0.1 Tom Palmer 5aug2011}{...}
{cmd:help bpbounds} {right:}
{hline}

{title:Title}

{p 5}{bf:bpbounds, bpboundsi} {hline 2} Nonparametric bounds for the causal effect in a binary instrumental variable model{p_end}

{title:Syntax}

{p 8 14 2}{cmd:bpbounds} {depvar} {cmd:(}{var:_endog} {cmd:=} {var:_iv}{cmd:)} {ifin} {weight} [{cmd:,} {opth fmt:(format)}]

{p 8 14 2}{cmd:bpboundsi} {it:#1 #2 #3 #4 #5 #6 #7 #8} [{cmd:,} {it:{help bpbounds##options:options}}]

{p 8 14 2}{cmd:bpboundsi} {it:#1 #2 #3 #4 #5 #6 #7 #8 #9 #10 #11 #12} [{cmd:,} {it:{help bpbounds##options:options}}]


{synoptset 24 tabbed}{...}
{marker options}{...}
{synopthdr:options}
{synoptline}
{p 6}{opt biv:ariate}{space 15}indicates bivariate/marginal data{p_end}
{synopt :{opth fmt:(format)}}change results format{p_end}
{p 6}{opt mat:rices(mnames)}{space 8}enter freqs/probs in matrices{p_end}
{synoptline}
{p 4 6 2}{cmd:fweight}s are allowed with {cmd:bpbounds}; see {help weight}.{p_end}
{p2colreset}{...}


{title:Description}

{pstd}Notation:{p_end}

{col 10}{depvar} ({it:Y}): {col 29}outcome variable (must be coded 0,1)
{col 10}{var:_endog} ({it:X}): {col 29}treatment received or exposure variable (must be coded 0,1)
{col 10}{var:_iv} ({it:Z}): {col 29}instrumental variable (must be coded 0,1 or 0,1,2)

{col 10}bivariate/marginal data: data on {{it:X},{it:Z}} in one sample and on {{it:Y},{it:Z}} in another.
{col 10}trivariate data: data on {{it:X},{it:Y},{it:Z}} in the same sample.

{pstd}{cmd:bpbounds} and its immediate form {cmd:bpboundsi} calculate the nonparametric bounds for the average causal effect (ACE) of Balke & Pearl (1997) for the all binary instrumental variable model (i.e. {{it:X},{it:Y},{it:Z}} all binary). 

{pstd}The commands also calculate the bounds on the intervention probabilities; P({it:Y}|do({it:X}=0)), P({it:Y}|do({it:X}=1)); and the causal risk ratio (CRR).

{pstd}The commands calculate these quantities for several extensions (Ramsahai, 2007 & 2008):{p_end}
{col 10}- bivariate/marginal data ({cmd:bpboundsi} only),
{col 10}- models with a three category instrument, 
{col 10}- assuming a monotonic effect of {it:Z} on {it:X}.

{pstd}The commands implement the polytope method of deriving the bounds (Bonet, 2001; Dawid, 2003). Polymake (Gawrilow and Joswig, 2000) and PORTA (version 1.4.1) were used to derive the polytope transformations.

{pstd}Notation for {cmd:bpboundsi}:{p_end}

{pstd}For trivariate data the inputs correspond to either cell counts (frequencies), where{p_end}
{col 10}{it:n}_{yx.z} = #({it:Y}=y,{it:X}=x|{it:Z}=z),
{pstd}or conditional probabilities,{p_end}
{col 10}{it:p}_{yx.z} = P({it:Y}=y,{it:X}=x|{it:Z}=z), 
{pstd}as shown in the Table below. For a two category instrument eight inputs are required, and 12 inputs are required for a three category instrument.{p_end}

{col 10}{bf:Trivariate data}
{col 10}Input {col 17}Freq. {col 27}Cond. prob.
{col 10}{it:#1} {col 17}{it:n}_{00.0} {col 27}{it:p}_{00.0}
{col 10}{it:#2} {col 17}{it:n}_{10.0} {col 27}{it:p}_{10.0}
{col 10}{it:#3} {col 17}{it:n}_{01.0} {col 27}{it:p}_{01.0}
{col 10}{it:#4} {col 17}{it:n}_{11.0} {col 27}{it:p}_{11.0}
{col 10}{it:#5} {col 17}{it:n}_{00.1} {col 27}{it:p}_{00.1}
{col 10}{it:#6} {col 17}{it:n}_{10.1} {col 27}{it:p}_{10.1}
{col 10}{it:#7} {col 17}{it:n}_{01.1} {col 27}{it:p}_{01.1}
{col 10}{it:#8} {col 17}{it:n}_{11.1} {col 27}{it:p}_{11.1}
{col 10}{it:#9} {col 17}{it:n}_{00.2} {col 27}{it:p}_{00.2} 
{col 10}{it:#10} {col 17}{it:n}_{10.2} {col 27}{it:p}_{10.2} 
{col 10}{it:#11} {col 17}{it:n}_{01.2} {col 27}{it:p}_{01.2} 
{col 10}{it:#12} {col 17}{it:n}_{11.2} {col 27}{it:p}_{11.2}

{pstd}For bivariate data the inputs correspond to either cell counts (frequencies), where{p_end}
{col 10}{it:ng}_{y.z} = #({it:Y}=y|{it:Z}=z) and {it:nt}_{x.z} = #({it:X}=x|{it:Z}=z),
{pstd}or conditional probabilities,{p_end}
{col 10}{it:g}_{y.z} = P({it:Y}=y|{it:Z}=z) and {it:t}_{x.z} = P({it:X}=x|{it:Z}=z),
{pstd}as shown in the Table below.{p_end}

{col 10}{bf:Bivariate data}
{col 10}Two category instrument {col 40}Three category instrument
{col 10}Input {col 17}Freq. {col 27}Cond. prob. {col 40}Input {col 47}Freq. {col 57}Cond. prob.
{col 10}{it:#1} {col 17}{it:ng}_{0.0} {col 27}{it:g}_{0.0} {col 40}{it:#1} {col 47}{it:ng}_{0.0} {col 57}{it:g}_{0.0}
{col 10}{it:#2} {col 17}{it:ng}_{1.0} {col 27}{it:g}_{1.0} {col 40}{it:#2} {col 47}{it:ng}_{1.0} {col 57}{it:g}_{1.0}
{col 10}{it:#3} {col 17}{it:ng}_{0.1} {col 27}{it:g}_{0.1} {col 40}{it:#3} {col 47}{it:ng}_{0.1} {col 57}{it:g}_{0.1}
{col 10}{it:#4} {col 17}{it:ng}_{1.1} {col 27}{it:g}_{1.1} {col 40}{it:#4} {col 47}{it:ng}_{1.1} {col 57}{it:g}_{1.1}
{col 10}{it:#5} {col 17}{it:nt}_{0.0} {col 27}{it:t}_{0.0} {col 40}{it:#5} {col 47}{it:ng}_{0.2} {col 57}{it:g}_{0.2}
{col 10}{it:#6} {col 17}{it:nt}_{1.0} {col 27}{it:t}_{1.0} {col 40}{it:#6} {col 47}{it:ng}_{1.2} {col 57}{it:g}_{1.2}
{col 10}{it:#7} {col 17}{it:nt}_{0.1} {col 27}{it:t}_{0.1} {col 40}{it:#7} {col 47}{it:nt}_{0.0} {col 57}{it:t}_{0.0}
{col 10}{it:#8} {col 17}{it:nt}_{1.1} {col 27}{it:t}_{1.1} {col 40}{it:#8} {col 47}{it:nt}_{1.0} {col 57}{it:t}_{1.0}
{col 10} {col 17} {col 27} {col 40}{it:#9} {col 47}{it:nt}_{0.1} {col 57}{it:t}_{0.1}
{col 10} {col 17} {col 27} {col 40}{it:#10} {col 47}{it:nt}_{1.1} {col 57}{it:t}_{1.1}
{col 10} {col 17} {col 27} {col 40}{it:#11} {col 47}{it:nt}_{0.2} {col 57}{it:t}_{0.2}
{col 10} {col 17} {col 27} {col 40}{it:#12} {col 47}{it:nt}_{1.2} {col 57}{it:t}_{1.2}


{title:Options}

{phang}
{opt biv:ariate} specifies bivariate/marginal data. The default is trivariate data.

{phang}
{opt fmt(format)} changes the displayed format of the results. The default is %5.4f. See {help format}.

{phang}
{opt mat:rices(mnames)} specifies either frequencies or conditional probabilities input in matrices.
The {it:X} categories must be the rows and the {it:Y} categories the columns.
The matrices must be listed in order;{p_end}
{col 10}for trivariate data: conditional on {it:Z}==0, {it:Z}==1, {it:Z}==2;
{col 10}for bivariate data: the {it:Z} by {it:Y} matrix then the {it:Z} by {it:X} matrix.


{title:Examples}

    {hline}
	
{pstd}{cmd:Example 1.} Vitamin A Supplementation example from Table 1 of Balke & Pearl (1997){p_end}

{phang}{cmd:. clear}{p_end}
{phang}{cmd:. input z x y count}{p_end}
{phang}{cmd:0 0 0 74}{p_end}
{phang}{cmd:0 0 1 11514}{p_end}
{phang}{cmd:1 0 0 34}{p_end}
{phang}{cmd:1 0 1 2385}{p_end}
{phang}{cmd:1 1 0 12}{p_end}
{phang}{cmd:1 1 1 9665}{p_end}
{phang}{cmd:end}{p_end}
{phang}{cmd:. bpbounds y (x = z) [fw=count]}{p_end}
{phang}{it:({stata "bpbounds_examples, eg(1)":click to run})}{p_end}

{phang}Perform analysis using {cmd:bpboundsi}{p_end}

{phang}{cmd:. bpboundsi 74 11514 0 0 34 2385 12 9665}{p_end}
{phang}{it:({stata "bpbounds_examples, eg(2)":click to run})}{p_end}

{phang}Input data using matrices (ensuring matrices are 2x2) {p_end}

{phang}{cmd:. tabulate x y if z==0, matcell(freqz0)}{p_end}
{phang}{cmd:. tabulate x y if z==1, matcell(freqz1)}{p_end}
{phang}{cmd:. mat list freqz0}{p_end}
{phang}{cmd:. mat freqz0 = (freqz0 \ 0 , 0)}{p_end}
{phang}{cmd:. mat list freqz0}{p_end}
{phang}{cmd:. mat list freqz1}{p_end}
{phang}{cmd:. bpboundsi, mat(freqz0 freqz1)}{p_end}
{phang}{it:({stata "bpbounds_examples, eg(3)":click to run})}{p_end}

{pstd}Input conditional probabilities as per Table 2 of Balke & Pearl (1997){p_end}

{phang}{cmd:. bysort z: tabulate x y [fw=count], cell}{p_end}
{phang}{cmd:. bpboundsi .0064 .9936 0 0 .0028 .1972 .001 .799}{p_end}
{phang}{it:({stata "bpbounds_examples, eg(4)":click to run})}{p_end}

{pstd}Treat the data as bivariate{p_end}

{phang}{cmd:. tab z y [fw=count], row matcell(zy)}{p_end}
{phang}{cmd:. tab z x [fw=count], row matcell(zx)}{p_end}
{phang}{cmd:. bpboundsi, mat(zy zx) biv}{p_end}
{phang}{it:({stata "bpbounds_examples, eg(5)":click to run})}{p_end}

{pstd}{cmd:Example 2.} Mendelian randomization example. Case-control data from Table 3 of Meleady et al. (2003) weighted to population frequencies assuming a prevalence of outcome 6.5%{p_end}

{pstd}Trivariate data with a 3 category instrument{p_end}

{phang}{cmd:. bpboundsi .83 .05 .11 .01 .88 .06 .05 .01 .72 .05 .20 0.03}{p_end}
{phang}{it:({stata "bpbounds_examples, eg(6)":click to run})}{p_end}

    {hline}


{title:Saved results}

{pstd}
{cmd:bpbounds} and {cmd:bpboundsi} save the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(inequality)}}IV inequality passed/failed (1/0){p_end}
{synopt:{cmd:r(bplb)}}Balke-Pearl lower bound for ACE{p_end}
{synopt:{cmd:r(bpub)}}Balke-Pearl upper bound for ACE{p_end}
{synopt:{cmd:r(p10lb)}}Lower bound for {it:P(Y|do(X=0))}{p_end}
{synopt:{cmd:r(p10ub)}}Upper bound for {it:P(Y|do(X=0))}{p_end}
{synopt:{cmd:r(p11lb)}}Lower bound for {it:P(Y|do(X=1))}{p_end}
{synopt:{cmd:r(p11ub)}}Upper bound for {it:P(Y|do(X=1))}{p_end}
{synopt:{cmd:r(crrlb)}}Lower bound for CRR{p_end}
{synopt:{cmd:r(crrub)}}Upper bound for CRR{p_end}
{p 6}{cmd:r(monoinequality)} Monotonicity inequality passed/failed (1/0){p_end}
{synopt:{cmd:r(monobplb)}}Lower bound for ACE under monotonicity{p_end}
{synopt:{cmd:r(monobpub)}}Upper bound for ACE under monotonicity{p_end}
{synopt:{cmd:r(monop10lb)}}Lower bound for {it:P(Y|do(X=0))} under monotonicity{p_end}
{synopt:{cmd:r(monop10ub)}}Upper bound for {it:P(Y|do(X=0))} under monotonicity{p_end}
{synopt:{cmd:r(monop11lb)}}Lower bound for {it:P(Y|do(X=1))} under monotonicity{p_end}
{synopt:{cmd:r(monop11ub)}}Upper bound for {it:P(Y|do(X=1))} under monotonicity{p_end}
{synopt:{cmd:r(monocrrlb)}}Lower bound for CRR under monotonicity{p_end}
{synopt:{cmd:r(monocrrub)}}Upper bound for CRR under monotonicity{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(bplower)}}Terms for ACE Balke-Pearl lower bound{p_end}
{synopt:{cmd:r(bpupper)}}Terms for ACE Balke-Pearl upper bound{p_end}
{synopt:{cmd:r(p10lower)}}Terms for {it:P(Y|do(X=0))} lower bound{p_end}
{synopt:{cmd:r(p10upper)}}Terms for {it:P(Y|do(X=0))} upper bound{p_end}
{synopt:{cmd:r(p11lower)}}Terms for {it:P(Y|do(X=1))} lower bound{p_end}
{synopt:{cmd:r(p11upper)}}Terms for {it:P(Y|do(X=1))} upper bound{p_end}
{synopt:{cmd:r(monolower)}}Terms for ACE lower bound under monotonicity{p_end}
{synopt:{cmd:r(monoupper)}}Terms for ACE upper bound under monotonicity{p_end}
{p 6}{cmd:r(monop10lower)} Terms for {it:P(Y|do(X=0))} lower bound under monotonicity{p_end}
{p 6}{cmd:r(monop10upper)} Terms for {it:P(Y|do(X=0))} upper bound under monotonicity{p_end}
{p 6}{cmd:r(monop11lower)} Terms for {it:P(Y|do(X=1))} lower bound under monotonicity{p_end}
{p 6}{cmd:r(monop11upper)} Terms for {it:P(Y|do(X=1))} upper bound under monotonicity{p_end}


{title:References}

{phang}Balke A, Pearl J. 1997. Bounds on treatment effects from studies with imperfect compliance. Journal of the American Statistical Association 92(439): 1172-1176.

{phang}Bonet B. 2001. Instrumentality tests revisited. In Proceedings of the Seventeenth Annual Conference on Uncertainty in Artificial Intelligence (UAI-01), 48-55. Morgan Kaufman, San Francisco, CA. 

{phang}Dawid AP. 2003. Causal inference using influence diagrams: The problem of partial compliance. In Highly Structured Stochastic Systems. p45-65. Oxford, UK: Oxford University Press.

{phang}Gawrilow E and Joswig, GM. 2000. polymake: a framework for analyzing convex polytopes. In Polytopes - Combinatorics and Computation. Kalai, G and Ziegler, GM (eds), p43-74, Birkhauser, Basel.

{phang}Meleady R, et al. 2003. Thermolabile methylenetetrahydrofolate reductase, homocysteine, and cardiovascular disease risk: the European Concerted Action Project. The American Journal of Clinical Nutrition 77(1): 63-70.

{phang}Palmer TM, Ramahai R, Didelez V, Sheehan NA. 2011. Nonparametric bounds for the causal effect in a binary instrumental variable model. The Stata Journal, submitted.

{phang}Ramsahai R. 2007. Causal Bounds and Instruments. In Proceedings of
the Twenty-Third Annual Conference on Uncertainty in
Artifcial Intelligence (UAI-07), 310-317. Corvallis, Oregon: AUAI Press.
http://uai.sis.pitt.edu/papers/07/p310-ramsahai.pdf

{phang}Ramsahai R. 2008. Causal Inference with Instruments and Other Supplementary Variables. Ph.D. thesis, Department of Statistics, University of Oxford.


{title:Authors}

{phang}Tom Palmer, Department of Mathematics and Statistics, Lancaster University, UK. 
 {browse "mailto:tom.palmer@lancaster.ac.uk":tom.palmer@lancaster.ac.uk}.{p_end}

{phang}Roland Ramsahai, Statistics Laboratory, University of Cambridge, UK.{p_end}

{phang}Vanessa Didelez, Department of Mathematics, University of Bristol, UK.{p_end}
 
{phang}Nuala Sheehan, Departments of Health Sciences and Genetics, University of Leicester, UK.{p_end} 
 
{title:Also see}

{psee}
Manual:  {manlink R biprobit}, {manlink R ivregress}, {manlink R ivprobit}

{psee}
{space 2}Help:  {manhelp biprobit R}, {manhelp ivregress R}, {manhelp ivprobit R}
{p_end}
