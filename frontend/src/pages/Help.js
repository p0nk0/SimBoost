import { createTheme, ThemeProvider } from '@mui/material/styles';
import { cyan } from '@mui/material/colors';
import Button from '@mui/material/Button';
import { Link } from "react-router-dom";

const theme = createTheme({
    palette: {
        primary: {
            main: '#512da8',
        },
        secondary: cyan,
        mode: "dark"
    },
});


export default function Help() {
    return (
        <div className="App">
            <header className="App-header">
            
                <ThemeProvider theme={theme}>
                <Link to="/">
                            <Button color="secondary" variant="outlined"> Home </Button>
                        </Link>
                    <h1 color="green">
                        Welcome to SimBoost!
                    </h1>
                    <h4> A Versatile Stock and Options Modeling Dashboard</h4>
                    <h5>Mission Statement</h5>
                    
                    <p id = "paragraph"> We strive to help you make the most profit from your stock and options trading endeavors by boosting the power of your simulations. However, it is risky to deploy models for your trading strategies with your assets without first testing which models are optimal for your needs. We provide multiple, customizable models to predict stock and options prices for various companies in the S&P500. Feel free to experiment to see what sorts of parameters make the most optimal predictions for companies you might be interested in trading over. We make predictions over historical stock data so you can see how accurate our model’s predictions were in comparison to the true data of the time.  </p>
                    <h5>How to Use</h5>
                    <p id = "paragraph"> <b> Three Simple Steps </b></p>
                    <ol>
                        <li class = "lists" id="paragraph">Choose ticker symbol on the left </li>
                        <li class = "lists" id="paragraph">Enter General Model Parameters (Start and End Date) </li>
                        <li class = "lists" id="paragraph">Enter model parameters specific to chosen model </li>
                        <li class = "lists" id="paragraph">Run model and see results! </li>
                    </ol>
                    <p id = "paragraph"> <b> Stock Price Prediction </b> </p>
                    <ul> <li class = "lists" id="paragraph"> <em> Monte Carlo </em> </li> </ul>
                    <p id = "paragraph"> We will use the average of 10000 Monte Carlo simulation to predict the daily stock prices over a timeframe that you specify. </p>
                    <p id = "paragraph"> Use the General Model Parameters to specify the start and ending dates over the entire time frame of stock data to be used in the model. </p>
                    <p id = "paragraph"> Enter a prediction start date within the Start and End dates of the general model. </p>
                    <p id = "paragraph"> Monte Carlo uses historical stock data from the General Start Date to Prediction Start Date to make daily stock predictions from the Prediction Start Date to General End Date. Predictions will also display on the graph along with a Mean Absolute Percentage Error!</p>
                    <p id = "paragraph"> <b> Option Contract Pricing </b> </p>
                    <ul> <li class = "lists" id="paragraph"> <em> Black Scholes </em> </li> </ul>
                    <p id = "paragraph"> Black Scholes predicts prices for Call Option and Put Option contracts of 100 shares per contract. We assume a European type option in this case. </p>
                    <p id = "paragraph"> Use the General Model Parameters to specify the start and ending dates over the entire time frame of stock data to be used in the model.  </p>
                    <p id = "paragraph"> Input a Start Date for your contract. The model uses historical stock data from General Start Date to Contract Start Date to price an option that starts on the Contract Start Date and expires on the General End Date.  </p>
                    <p id = "paragraph"> Our model will provide the price for your Call/Put option and the PNL that you would have made if you traded the stock at the strike price of the contract and ending stock price of the company that you chose, taking into account the price of the option. </p>
                    <ul> <li class = "lists" id="paragraph"> <em> Binomial Pricer </em> </li> </ul>
                    <p id = "paragraph"> Black Scholes predicts prices for Call Option and Put Option contracts of 100 shares per contract. We assume a European type option in this case. </p>
                    <p id = "paragraph"> Use the General Model Parameters to specify the start and ending dates over the entire time frame of stock data to be used in the model.  </p>
                    <p id = "paragraph"> Input a Start Date for your contract. The model uses historical stock data from General Start Date to Contract Start Date to price an option that starts on the Contract Start Date and expires on the General End Date.  </p>
                    <p id = "paragraph"> Our model will provide the price for your Call/Put option and the PNL that you would have made if you traded the stock at the strike price of the contract and ending stock price of the company that you chose, taking into account the price of the option. </p>
                    
                    
                    </ThemeProvider>


                
            </header>
        </div>
    )
}