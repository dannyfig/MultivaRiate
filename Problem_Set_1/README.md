## Problem Set 1

#### Instructions
Gather data where there is a numerical response variable, and one numerical potential predicting variable. Your sample should consist of 
at least 30 data values. Analyze the data in a full and appropriate fashion using any methods and techniques that are appropriate, 
and discuss what you find.

#### Summary
I gathered my data using [NYC Open Data](https://data.cityofnewyork.us/) and specifically sourced a [dataset](https://data.cityofnewyork.us/Education/SAT-College-Board-2010-School-Level-Results/zt9s-n5aj) 
that reported 2010 SAT scores broken down by the Critical Reading, Math, and Writing sections. Each observation is a high school, with the reported 
scores resulting from the mean SAT scores from 2010 college-bound seniors. I wanted to find out more about CollegeBoard's recent decision
to [make the essay (Writing) section optional](http://www.bloomberg.com/news/articles/2014-03-05/college-board-redesigns-sat-exam-making-essay-portion-optional),
and figured that if there was a close enough correlation between Critical Reading and Writing scores, we could reasonably say that the SAT
skewed scores in favor of those who were stronger at the humanities.

#### Challenges
In the original dataset, schools with 5 or fewer college-bound seniors had their information suppressed and their rows were essentially null values (`s` for `suppressed`). My R script accounts for this by performing
some basic data cleaning before jumping into the actual data analysis. Upon reading the dataset into R, the SAT scores were treated as
character values so there was also some conversion that needed to be done in order to treat them as numerical data.

#### Retrospective
Writing my own R script was a great head-first introduction to R. There were some similarities to Python's `pandas` framework, but
for the most part the concepts and ideas were new to me. I adapted some code provided by my professor -- specifically, the 
`regplot.confbands.fun` function -- in order to determine the function for the fitted plot (ideally, I would have written this on my own. 
That said, there's no need to reinvent the wheel). Trying to work with ggplot2 has also been *great fun*, but it's evidently not something to be 
mastered (or learned, for that matter) overnight.

For information regarding my analysis, feel free to check out my statistical report! It's the only PDF in this directory.

Questions and feedback are always welcome! Feel free to contact me through GitHub or email me at <danny.vilela@nyu.edu>.
