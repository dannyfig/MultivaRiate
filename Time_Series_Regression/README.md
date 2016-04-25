## Time Series Regression

#### Instructions

Gather data where there is a numerical response variable, and at least three numerical
potential predicting variables (not including transformed versions of the response or other
predictors), and the cases are ordered in time (e.g., divorce rates from marriage rates,
birth rates, percentage of the female population that have a college degree, and per capita
income for New York during the years 1940–2012; national unemployment rate from prime
interest rate, return on the S&P 500, change in the U.S. dollar/Euro exchange rate, and
inflation rate for quarters in 1974–2013; etc.). You can use time itself as a predictor if you
wish, but there should be at least three (potential) predictors in your model other than
time. There should be at least 30 data points (that is, 30 time points at which data were
measured). Perform a complete and full analysis of the regression model, being careful
to check all appropriate assumptions and provide all relevant discussion. Use corrective
procedures where necessary. Discuss the implications of your results.

For full instructions, see [here](http://people.stern.nyu.edu/jsimonof/classes/2301/pdf/hw4.pdf).

#### Summary

I gathered my data using Yahoo Finance's online historical prices form that lets you query a stock's
historical prices. This time, I looked at [Tesla](http://finance.yahoo.com/q/hp?a=&b=&c=&d=3&e=25&f=2016&g=d&s=TSLA%2C+&ql=1)'s stock
price since its initial public offering. Each observation represents the weekly progression of Tesla's stock price. I attempted to utilize
Google's search interest to see if that helped our prediction model, but to little avail. In the end, it turns out that using last week's
stock price is the best predictor for this week's price -- who knew?

#### Challenges

This time around, I was prepared and eager to use R packages that would make my life easier. In particular, I was able to incorporate
the [```pacman```](https://github.com/trinker/pacman) and [```dplyr```](https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html) packages for easy package installation and straight-forward data manipulation, respectively.
Furthermore, I spent a *ton* of time getting the right plots going, and I'm pretty proud of how they've turned out. Working with data for this
report actually inspired me to go binge shopping for books on R data visualization (super cool, I know), including Winston Chang's [```R Graphics Cookbook```](http://www.amazon.com/R-Graphics-Cookbook-Winston-Chang/dp/1449316956?ie=UTF8&psc=1&redirect=true&ref_=oh_aui_detailpage_o01_s00)
and Hadley Wickham's [```ggplot2```](http://www.amazon.com/ggplot2-Elegant-Graphics-Data-Analysis/dp/0387981403?ie=UTF8&psc=1&redirect=true&ref_=oh_aui_detailpage_o00_s00).
Looking forward to getting some cool visualization work done soon.

Otherwise, this report was pretty challenging in terms of understanding the "why"s of the data. Tesla's stock saw a meteoric rise
that I couldn't explain through just data analysis. It was interesting to research why investors started pouring into Tesla in Q1 of 2014 and
explaining that factor in my report.

#### Retrospective

Although I didn't need to beat the R syntax into my head this time, I noted how much easier R had gotten. Aside from these reports, I've
used R to work on the data analysis pipeline at the on-campus research lab I'm part of and it's been incredibly useful there. I'm still more
fluent with the Python ecosystem, but R is definitely growing on me. Happy to say I'm seeing the light.

For information regarding my analysis, feel free to check out my statistical report! It's the only PDF in this subdirectory (Report.pdf, although you might want to spare GitHub's online file viewer and clone the repo to look at it locally).

Questions and feedback are always welcome! Feel free to contact me through GitHub or email me at <danny.vilela@nyu.edu>.
