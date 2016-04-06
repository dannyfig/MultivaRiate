## Multiple Linear Regression

#### Instructions
Gather data where there is a numerical response variable and at least four numerical potential predicting variables. An indicator variable 
defining membership in one of two groups counts as a numerical variable, but at least two of your numerical predictors should not be indicator 
variables. Any variables you might create during the analysis, such as product or squared variables, do not count to the minimum of four. 
There should be at least 30 data points. Do a full and complete analysis of what is going on in the data, being sure to build your chosen 
model using all of the methods and principles we have discussed in class, and being sure to check assumptions. 

For full instructions, see [here](http://people.stern.nyu.edu/jsimonof/classes/2301/pdf/hw3.pdf).

#### Summary
I gathered my data using [guoguo12's](https://github.com/guoguo12/billboard-charts) ```billboard-charts``` Python wrapper for scraping data from Billboard.com.
Each observation is a song from a particular chart date, so there was a ton of overlap within our data. I wanted to discover if artists
could predict how well a song would do given the current chart rankings and some calculated predictors. I discovered that, unfortunately, my
model does not completely represent our data and -- subsequently -- does not contain the best predictors for predicting a song's peak chart
position.

#### Challenges
This report was much more involved than [my previous simple linear regression report](https://github.com/dannyfig/MultivaRiate/tree/master/Simple_Linear_Regression).
Not only did this dataset include an incredible amount of overlapping data (which required that I consider the effects certain predictors
might have before involving them in my model), it also proved difficult to work with computationally. Furthermore, one of the predictors I
had a strong belief would influence my model ```concurrent.count``` -- which would calculate the number of songs an artist had on a unique chart date
-- was *incredibly* computationally expensive and when it was around 80% done, my laptop kinda just...died. I didn't have enough time to re-compute
the values (blame my procrastinating habits), so I couldn't include it in the model. Sometime in the future I'll revisit this and update the
model.

Otherwise, this task was also more involved in general. It required more familiarity with R as a programming language and how to *really*
work with dataframes. I'm not proud of using ```for``` loops in R, but I did what had to be done. Next time, I'll try going a more functional
route.

#### Retrospective
Again, I really got a great appreciation for R through this project. While doing some late-night troubleshooting I was exposed to tons of
resources for improving my "data analysis with R"-game, including things like (R Markdown)[http://rmarkdown.rstudio.com/] and (Learning R)[https://github.com/pawelmb57/LearningR],
which I'll hope to incorporate into future assignments. This time I didn't adapt any R code from outside sources, and ggplot2 is still a
mystery to me -- but that'll change soon enough.

For information regarding my analysis, feel free to check out my statistical report! It's the only PDF in this subdirectory (Report.PDF, although you might want to spare GitHub's online file viewer and clone the repo to look at it locally).

Questions and feedback are always welcome! Feel free to contact me through GitHub or email me at <danny.vilela@nyu.edu>.
