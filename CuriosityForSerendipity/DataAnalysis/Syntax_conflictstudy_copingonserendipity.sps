ALTER TYPE  familiarGenre favoriteActor intrigue mood favoriteDirector mind (f7.2).
ALTER TYPE discoverPlaces learnSubjects listenMusic strangeSound machinery solution (f7.2).
ALTER TYPE influenceDecision outOfScope unexpected usefulIdeas (f7.2).
ALTER TYPE user (f7.2).

* Recode Likert scale ratings in a 1-5 scale.
RECODE familiarGenre favoriteActor intrigue mood favoriteDirector mind (6=1) (7=2) (8=4) (9=5).
EXECUTE.

*Recode string value of gender to numerical value.
RECODE Gender ('Male'='1') ('Female'='2').
EXECUTE.

RECODE Age ('16-20'='1')('21-30'='2')('31-40'='3')('41-50'='4')('51-60'='5')('61-70'='6')('71-80'='7').
EXECUTE.

*Alter type of variables to numerical.
ALTER TYPE Gender (f7.2).
ALTER TYPE Age (f7.2).
ALTER TYPE Education(f7.2).
VARIABLE LEVEL Age Education(ORDINAL). 
ALTER TYPE Country(f7.2).
VALUE LABELS  Gender 1 'Male' 2 'Female'.
VALUE LABELS Age 1 '16-20' 2 '21-30' 3 '31-40' 4 '41-50' 5 '51-60' 6 '61-70' 7 '71-80'.


* ---- create user profile variables for curiosity and recommendation serendipity experiences ----

* rename coping style variables to type of curiosity:
- PC = perceptual curiosity
- EC = epistemic curiosity
- S = specific exploratory behavior
- D = diversive exploratory behavior.

RENAME VARIABLES (discoverPlaces=PCDdiscoverPlaces).
EXECUTE.

RENAME VARIABLES (learnSubjects =ECDlearnSubjects).
EXECUTE.

RENAME VARIABLES (listenMusic =PCDlistenMusic).
EXECUTE.

RENAME VARIABLES (strangeSound=PCSstrangeSound).
EXECUTE.

RENAME VARIABLES (machinery=ECDmachinery).
EXECUTE.

RENAME VARIABLES (solution=ECSsolution).
EXECUTE.

* Compute curiosity style scores, create average of each type of curiosities.
COMPUTE PCscore=MEAN(PCDdiscoverPlaces, PCDlistenMusic, PCSstrangeSound).
EXECUTE.

COMPUTE ECscore=MEAN(ECDlearnSubjects,ECDmachinery, ECSsolution).
EXECUTE.

COMPUTE Sscore=MEAN(PCSstrangeSound, ECSsolution).
EXECUTE.

COMPUTE Dscore=MEAN(PCDdiscoverPlaces, PCDlistenMusic, ECDlearnSubjects, ECDmachinery).
EXECUTE. 

COMPUTE AllCuriosityAverage=MEAN(PCSstrangeSound,ECDmachinery, ECSsolution, PCDdiscoverPlaces, PCDlistenMusic,PCSstrangeSound).
EXECUTE.


* Bin curiosity style scores on high and low (for PC, EC , D and S). 
*Only include items when 'agree or completely agree' at least 2/3 answers for 'high' group, else 'low' group.
DO IF (PCscore>=3.5).
COMPUTE PCscoreBin=1.
ELSE IF (PCscore<3.5).
COMPUTE PCscoreBin=0.
END IF.
EXECUTE.

DO IF (ECscore>=3.5).
COMPUTE ECscoreBin=1.
ELSE IF (ECscore<3.5).
COMPUTE ECscoreBin=0.
END IF.
EXECUTE.

DO IF (Dscore>=3.5).
COMPUTE DscoreBin=1.
ELSE IF (Dscore<3.5).
COMPUTE DscoreBin=0.
END IF.
EXECUTE.

DO IF (Sscore>=3.5).
COMPUTE SscoreBin=1.
ELSE IF (Sscore<3.5).
COMPUTE SscoreBin=0.
END IF.
EXECUTE.

VALUE LABELS PCscore ECscore Dscore Sscore 1 'high' 0 'low'.

FREQUENCIES VARIABLES=PCscore  ECscore Sscore Dscore
  /FORMAT=NOTABLE
  /HISTOGRAM
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES= PCscoreBin  ECscoreBin SscoreBin DscoreBin
   /FORMAT=NOTABLE
   /HISTOGRAM
   /ORDER=ANALYSIS.

* Create 4 curiosity styles, based on the high vs. low scored scales:
Curiosity style 1 - high on both levels (PC & EC)
Curiosity style 2 - high on PC, low on EC
Curiosity style 3 - low on PC, high on EC
Curiosity style 4 - low on both levels (PC & EC).

DO IF (PCscoreBin=1 AND ECscoreBin=1).
COMPUTE CuriosityStyle=1.
ELSE IF (PCscoreBin=1 AND ECscoreBin=0).
COMPUTE CuriosityStyle=2.
ELSE IF (PCscoreBin=0 AND ECscoreBin= 1).
COMPUTE CuriosityStyle=3.
ELSE IF (PCscoreBin=0 AND ECscoreBin=0).
COMPUTE CuriosityStyle=4.
END IF.
EXECUTE.

VALUE LABELS PCscoreBin ECscoreBin DscoreBin SscoreBin 1 'high' 0 'low'.

FREQUENCIES VARIABLES=CuriosityStyle
  /FORMAT=NOTABLE
  /HISTOGRAM
  /ORDER=ANALYSIS.

VALUE LABELS CuriosityStyle 1 'Perceptual and Epistemic high' 2 'Perceptual high Epistemic low' 3 'Epistemic high Perceptual low' 4 'Perceptual and Epistemic low'.
VARIABLE LEVEL  CuriosityStyle(NOMINAL).

* Compute serendipity scales.
COMPUTE RecomExperience=MEAN(influenceDecision, outOfScope, unexpected, usefulIdeas).
EXECUTE.

DO IF (RecomExperience>3.5).
COMPUTE RecomExperienceBin=3.
ELSE IF (RecomExperience >2.5).
COMPUTE RecomExperienceBin=2.
ELSE IF (RecomExperience<=2.5).
COMPUTE RecomExperienceBin=1.
END IF.
EXECUTE.

VALUE LABELS RecomExperienceBin 1 'low' 2 'med' 3 'high'.

FREQUENCIES VARIABLES=RecomExperienceBin
  /FORMAT=NOTABLE
  /HISTOGRAM
  /ORDER=ANALYSIS.

*----------- Start analysis curiosity as personality trait-----.
NONPAR CORR
  /VARIABLES=PCscore ECscore Sscore Dscore AllCuriosityAverage influenceDecision outOfScope unexpected usefulIdeas
  /PRINT=SPEARMAN TWOTAIL NOSIG
  /MISSING=PAIRWISE.

*---Logit regression---*

PLUM influenceDecision WITH PCscore ECscore
  /CRITERIA=CIN(95) DELTA(0) LCONVERGE(0) MXITER(100) MXSTEP(5) PCONVERGE(1.0E-6) SINGULAR(1.0E-8)
  /LINK=LOGIT
  /PRINT=FIT PARAMETER SUMMARY TPARALLEL.

PLUM unexpected WITH PCscore ECscore
  /CRITERIA=CIN(95) DELTA(0) LCONVERGE(0) MXITER(100) MXSTEP(5) PCONVERGE(1.0E-6) SINGULAR(1.0E-8)
  /LINK=LOGIT
  /PRINT=FIT PARAMETER SUMMARY TPARALLEL.

PLUM outOfScope WITH PCscore ECscore
  /CRITERIA=CIN(95) DELTA(0) LCONVERGE(0) MXITER(100) MXSTEP(5) PCONVERGE(1.0E-6) SINGULAR(1.0E-8)
  /LINK=LOGIT
  /PRINT=FIT PARAMETER SUMMARY TPARALLEL.

PLUM usefulIdeas WITH PCscore ECscore
  /CRITERIA=CIN(95) DELTA(0) LCONVERGE(0) MXITER(100) MXSTEP(5) PCONVERGE(1.0E-6) SINGULAR(1.0E-8)
  /LINK=LOGIT
  /PRINT=FIT PARAMETER SUMMARY TPARALLEL.


*---- Friedman test with 6 factors (reasons) for watching a TV recommendations; is there a difference between importance of factors for selecting TV show? ---*.
NPAR TESTS
  /FRIEDMAN=familiarGenre favoriteActor favoriteDirector intrigue mood mind
  /MISSING LISTWISE.

*--Wilcoxon test for not normally distributed t-test of factors; which of the factors is most important?--*.
NPAR TESTS
  /WILCOXON=intrigue intrigue intrigue intrigue intrigue WITH mind mood familiarGenre favoriteActor favoriteDirector (PAIRED)
  /MISSING ANALYSIS.

NPAR TESTS
  /WILCOXON=mind mind mind mind WITH  mood familiarGenre favoriteActor favoriteDirector (PAIRED)
  /MISSING ANALYSIS.


NPAR TESTS
  /WILCOXON=mood mood mood WITH  familiarGenre favoriteActor favoriteDirector (PAIRED)
  /MISSING ANALYSIS.

NPAR TESTS
  /WILCOXON=familiarGenre familiarGenre WITH  favoriteActor favoriteDirector (PAIRED)
  /MISSING ANALYSIS.

NPAR TESTS
  /WILCOXON= favoriteActor WITH  favoriteDirector (PAIRED)
  /MISSING ANALYSIS.

NPAR TESTS
  /WILCOXON=intrigue intrigue intrigue  WITH familiarGenre favoriteActor favoriteDirector (PAIRED)
  /MISSING ANALYSIS.

NPAR TESTS
  /WILCOXON= familiarGenre familiarGenre WITH favoriteActor favoriteDirector (PAIRED)
  /MISSING ANALYSIS.

NPAR TESTS
  /WILCOXON= favoriteActor WITH  favoriteDirector (PAIRED)
  /MISSING ANALYSIS.



