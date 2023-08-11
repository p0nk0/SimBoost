# stock-price-predictor
## SimBoost - Stock and Options Pricer
_By: Sonica Prakash and Taylor Roberts_

### About the Program 

SimBoost is an interactive web interface that allows users to adjust parameters for models to predict stock prices over a time series and to provide optimal contract prices for Option Call contracts and Option Put contracts. There are 10 stocks to customize models on across various industry sectors. Each model has different parameters that can be altered on the interface, and relevant graphs of stock prices, accuracy metrics, and/or predicted PNL will appear. 

To use, choose a stock to investigate, enter the model parameters in the textboxes below the graph, and then click on the model name to run. Default parameters are set. Below, we will describe which parameters each model takes. 

The models work by using a subset of historical stock data (from the NASDAQ Financial Data API) to predict over a relative "future" subset of historical data for the same stock so that you can judge the effects of models parameters on accuracy. 

### Installation and Setup 

You will need to install the following libraries with the following commands for OCaml: 

- Owl Base: opam install owl-base
- Cohttp Async: opam install cohttp-async
- JSONAF : opan install jsonaf

You will also need to install React. Within React, you will need to install the following packages using npm. 

- material-ui
- material-ui-x-date-pickers
- material-ui-x-charts
- day-js
- react-router-dom

Once you have the repo downloaded, change into the 'frontend' directory and use the command 'npm start' to start the application!

### Current Models 

#### Options

There are two models for options. Here is a description of the parameters that are relevant to both: 

We use historical stock data to estimate historical volatility of the stock. Use the **General Start Date** to indicate the start date of the historical data. Use the **General End Date** to indicate the expiration date of the contract (we assume the European Options model in which option contracts are executed on expiration date). Use the **Prediction Start Date** under the Model Parameters to indicate the what is both the Start Date of the options contract and the End Date of the historical stock data that the model should be using for its parameters. 

Chronologically, the dates should go from General Start Date < Prediction Start Date < General End Date

Click on the Put or Call button under model parameters based on which contract you are expecting to purchase. Specify the Strike Price and Interest Rate for your contracts also under model parameters. 

##### Black-Scholes 

Black-Scholes requires no additional parameters. Click on the Black-Scholes button after inputting all parameters (or leaving the defaults) to run the model. The stock price at expiration, the prediction contract price for your option, and the estimated PNL will be displayed as results. 

##### Binomial Pricing 

Binomial Pricing requires an addition parameter, Number of Time Steps under model parameters that dictates how big the tree should be in use for the binomial pricing calculation. Click on the Binomial Pricer button after inputting all parameters (or leaving the defaults) to run the model. The stock price at expiration, the prediction contract price for your option, and the estimated PNL will be displayed as results. 

##### Calculating PNL 

All contracts are assumed to be for 100 shares of a specific stock. 

For a Call option, the PNL is calculated by (Selling 100 shares at Stock Price @ Expiration) - (Contract Price) - (Buying 100 shares at Strike Price 100 for shares). 

For a Put option, the PNL is calculated by (Buying 100 shares at Stock Price @ Expiration) - (Contract Price) - (Selling 100 shares at Strike Price for 100 shares). 

#### Stocks 

There is one model for stocks, with parameters described below. 

##### Monte Carlo

Volatility is calculated using historical stock data for your chosen stock from General Start Date to Prediction Start Date. Daily stock price predictions are then made (and shown on the graph) from Prediction Start Date to General End Date. The displayed prediction of stock prices is the average of 10,000 simulations of Monte Carlo. 

The result displayed is the Mean Absolute Percentage Error (MAPE) between the true stock prices and the predicted stock prices. 


