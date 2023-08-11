# stock-price-predictor
## SimBoost - Stock and Options Pricer
_By: Sonica Prakash and Taylor Roberts_

### About the Program 

SimBoost is an interactive web interface that allows users to adjust parameters for models to predict stock prices over a time series and to provide optimal contract prices for Option Call contracts and Option Put contracts. There are 10 stocks to customize models on across various industry sectors. Each model has different parameters that can be altered on the interface, and relevant graphs of stock prices, accuracy metrics, and/or predicted PNL will appear. 

To use, choose a stock to investigate, enter the model parameters in the textboxes below the graph, and then click on the model name to run. Default parameters are set. Below, we will describe which parameters each model takes. 

The models work by using a subset of historical stock data (from the NASDAQ Financial Data API) to predict over a relative "future" subset of historical data for the same stock so that you can judge the effects of models parameters on accuracy. 

### Installation and Setup 

### Current Models 

#### Options

We use historical stock data to estimate historical volatility of the stock. Use the General Start Date to indicate the start date of the historical data. Use the General End Date to indicate the expiration date of the contract (we assume the European Options model in which option contracts are executed on expiration date). Use the Prediction Start Date under the Model Parameters 

##### Black-Scholes 

##### Binomial Pricing 

#### Stocks 

##### Monte Carlo


