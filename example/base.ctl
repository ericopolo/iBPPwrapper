seed = -1     * change this to positive integer to fix the seed

seqfile = seqs.txt
Imapfile = map.txt
traitfile = morph.txt
outfile = out.txt
mcmcfile = mcmc.txt

speciesdelimitation = 1 * you may leave this unchanged for iBPPwrapper, for it will always perform species delimitation

uniformrootedtrees = 1         * 0 means uniform labeled histories
                  
                 
species&tree = 4  1 2 3 4
                  2 2 2 2
                  (((1,2),3),4);

                  
*       usedata = 1    * 0: no data (prior); 1:seq & trait like
    useseqdata = 1    * 0: no seq data;     1:seq like
  usetraitdata = 1    * 0: no trait data;   1:trait like
         nloci = 10    * number of loci that will be ramdomly drawn every run (<= total loci you have)
       ntraits = 1    * number of trait variables
         nindT = 8    * total # individuals for which trait data is available

     cleandata = 0    * remove sites with ambiguity data? (1:yes, 0:no)

    thetaprior = 3 20    # gamma(a, b) for theta
      tauprior = 3 3 1  # gamma(a, b) for root tau & Dirichlet(a) for other tau's
           nu0 = 0         # parameters for prior on traits
        kappa0 = 0         # nu0=0 and kappa0=0 for non-informative prior

*      heredity = 0 4 4   # (0: No variation, 1: estimate, 2: from file) & a_gamma b_gamma (if 1)
     locusrate = 1 2.0   # (0: No variation, 1: estimate, 2: from file) & a_Dirichlet (if 1)
* sequenceerror = 0 0 0 0 0 : 0.05 1   # sequencing errors: gamma(a, b) prior

     # auto (0 or 1): finetune for GBtj, GBspr, theta, tau, mix, locusrate, seqerr, traitHsq
     finetune = 1: .01 .01 .01 .01 .01 .01 .01 .01 .01

         print = 1
        burnin = 2000 *initial burnin value
      sampfreq = 1 *initial sampfreq value
       nsample = 1000
