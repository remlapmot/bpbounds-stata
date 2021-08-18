# Balke-Pearl nonparametric bounds for the average causal effect implemented in Stata

The `bpbounds` command and its immediate form, `bpboundsi`, calculate the nonparametric bounds for the average causal effect (ACE) of Balke & Pearl (1997) for the all binary instrumental variable model (i.e. exposure/treatment *X*, outcome *Y*, and instrumental variable *Z* all binary).

The commands also calculate the bounds on the intervention probabilities; P(*Y*|do(*X*=0)), P(*Y*|do(*X*=1)); and the causal risk ratio.

The commands calculate these quantities for several extensions (Ramsahai, 2007 & 2008):

- bivariate/marginal data (bpboundsi only),
- models with a three category instrument, 
- assuming a monotonic effect of Z on X.

## Installation
To install, issue in Stata (in versions 13 and above):
``` stata
net install bpbounds, from("https://raw.github.com/remlapmot/bpbounds-stata/master/") 
```

## References

- Balke A, Pearl J. 1997. Bounds on treatment effects from studies with imperfect compliance. Journal of the American Statistical Association 92(439): 1172-1176. [DOI: 10.1080/01621459.1997.10474074](https://doi.org/10.1080/01621459.1997.10474074)
-  Ramsahai R. 2007. Causal Bounds and Instruments. In Proceedings of the Twenty-Third Annual Conference on Uncertainty in Artifcial Intelligence (UAI-07), 310-317. Corvallis, Oregon: AUAI Press.  http://uai.sis.pitt.edu/papers/07/p310-ramsahai.pdf
- Ramsahai R. 2008. Causal Inference with Instruments and Other Supplementary Variables. Ph.D. thesis, Department of Statistics, University of Oxford.
