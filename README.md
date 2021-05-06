
# iBPPwrapper

As you probably already guessed, iBPPwrapper is a wrapper for running iBPP (https://github.com/cecileane/iBPP). Specifically, it automates species delimitation with iBPP using either sequence data, morphological traits or both. It's basic function is to run multiple delimitation analyses, beginning with shorter ones and gradually prolonging them until the MCMC chain stabilizes. This is accomplished by adjusting burn-in length and/or sampling frequency based on ESS values from previous runs. Additionally, for each run it randomly chooses between the iBPP delimitation algorithm used (0 or 1) and among values for their parameters informed by the user. More importantly, on each run it will select a random subset of loci from the sequences file provided, with a size determined by the user. The main idea behind this is that, besides speeding up the individual analyses when using data at genomic scales, the alternations between algorithm parameters and loci subsets could provide more certainty about the convergence among independent runs.

iBPPwrapper is consisted by two separated modules, a Perl script (iBPPwrapper.pl) and an R script (iBPPwrapper.R). The Perl script controls the execution of iBPP runs and the R script calculates ESS values on all parameters, also checking whether larger burn-in values would increase ESS. Example files are provided (examples/ sub-directory), and below you will find a dependencies list and a (quick) guide explaining the main adjustments you should be concerned about.


## Dependencies

Before running iBPPwrapper, you must make sure you have the following prerequisites installed:

iBPP: https://github.com/cecileane/iBPP

R package “LaplacesDemon”: available on CRAN (execute `install.packages(“LaplacesDemon”)` from inside R)

Although Perl and R interpreters are obviously needed, they already come on repositories from most Linux distributions, and it should be straight forward to install them in your favorite penguin flavor. I imagine MacOS users won’t have bigger problems using iBPPwrapper, either, but I haven’t tested it there. As for strict Windows users working with Computational Biology, I strongly suggest you should consider learning how to use the new available WSL (Windows Subsystem Linux).


## Getting things ready to work

Once you have all dependencies satisfied, download iBPPwrapper by clicking Code > download ZIP on this page or, if you have git installed:

`git clone https://github.com/erico171/iBPPwrapper.git`

Make sure both scripts are executable:

`chmod +x iBPPwrapper*`

The R script (iBPPwrapper.R) is interpreted by the Rscript program, installed with R. The first line of the script instructs the shell to use /usr/bin/env to locate it, but maybe you’ll have to change it depending on your system. On Linux the better way to locate the Rscript program is with the command

`which Rscript`

then you can copy the path provided and replace `/usr/bin/env Rscript` inside iBPPwrapper.R with it. An alternative should be include `Rscript` before the path for iBPPwrapper.R in your configuration file (see about this file below). Likewise, the Perl script is telling the shell to search for the Perl interpreter in `/usr/bin/perl`, so change it if necessary. You can also skip that and just call it with perl instead of doing it directly.

Finally, everything becomes easier when you can execute both scripts from any directory, what makes it necessary to either add the iBPPwrapper directory to your PATH or copy both scripts to a directory that’s already in there. If it is harder for you to understand what I’m talking about than my usual English already is, just forget it and copy the scripts to the same directory your input files are, every time you need it – they are very small, anyway.


## Quick guide

First of all, you should be totally familiarized with iBPP before using this wrapper, as the automation occurs only for the execution of multiple runs, not the configuration of the parameters themselves. If you already didn’t, make sure you’ve read the manual of both iBPP and BPP and successfully made some iBPP runs.

The quicker way to get the hang of the wrapper is to examine and run the example files. The command to run it is:

`iBPPwrapper.pl params.cfg`

It should end very quickly, as the configuration file `params.cfg` is telling the wrapper to stop after only 5 runs. You probably will need much more than that to get stable results. The configuration file is commented and should be very easy to understand and edit for anyone familiarized with iBPP. Another file that needs your attention is the iBPP configuration file `base.ctl`. It is the very same file we set in iBPP, with special observations for four parameters, concerning our wrapper:

`speciesdelimitation`: normally this is where we define whether species will be delimited, which algorithm to use and the values for their parameters. For the wrapper it doesn’t matter what is configured, as long as it finds the term “speciesdelimitation”. Species delimitation will always be estimated, algorithms 0 and 1 will alternate randomly through runs and the values for the parameters will be drawn from the values set in the params.cfg file.

`nloci`: rather than the total number of loci you have available in your sequences file, here it is the number of loci that will be randomly drawn from there on each run. Ideally it should not exceed a few dozen loci, as we usually need a lot of independent runs, but see a little more on that below.

`burnin` and `sampfreq`: these two parameters will determine only the initial values for burn-in and sampling frequency, as they can be incremented after each run, depending on the ESS values obtained. The length of the burn-in affects ESS values and auto finetune (when it’s used), and is determined only by the “burnin” parameter. The total post-burn-in length, on the other hand, is given by sampfreq x nsample, and I could increment anyone of them (or even both) in the attempts to increase ESS values. But I chose to fix nsample and increment only sampfreq (i.e. number of iterations between samples taken) because a lower frequency will also produce a lower autocorrelation between samples, and by fixing nsample we control the number of samples from the posterior we’ll keep at the end.

While running, the wrapper will print relevant information for each run, which will also be saved in a tabulation separated file (.tsv). The `algorithm` column contains the delimitation algorithms numbers used and the values for their parameters, using the same notation as in BPP. You should see the `burnin` and `sampfreq` values being incremented every time the `worstESS` (i.e., the lower ESS value across all MCMC parameters, for that specific run) is below the `goodESS` threshold defined in the `params.cfg` file. The `initialSppTree` and `finalSppTree` contain the BPP notation for the initial and final species tree of each run, respectively.

Theoretically, you should be satisfied when you have got “a lot” of different algorithm parameters with different initial trees, all with the same final tree and worst ESS values being “good” ones. My suggestion is that you try that first using only a very few loci (e.g. 10), and then increase this value if you get many different final trees even with stable individual runs.

## Citing

If you use iBPPwrapper, make sure you cite the people behind the actual wonderful tools:

iBPP:

Claudia Solís-Lemus, L. Lacey Knowles and Cécile Ané (2014). Bayesian species delimitation combining multiple genes and traits in a unified framework. Evolution 69(2):492-507.

BPP:

Ziheng Yang and Bruce Rannala (2010). Bayesian species delimitation using multilocus sequence data. PNAS 107:9264–9269

LaplacesDemon R-package:

Statisticat, LLC. (2020). LaplacesDemon: Complete Environment for Bayesian Inference. Bayesian-Inference.com. R package version 16.1.4. [https://web.archive.org/web/20150206004624/http://www.bayesian-inference.com/software]
