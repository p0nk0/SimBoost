import { useState, useEffect } from 'react';
import '../App.css';

import { Link } from "react-router-dom";

import { createTheme, ThemeProvider } from '@mui/material/styles';
import { cyan } from '@mui/material/colors';

import CircularProgress from '@mui/material/CircularProgress';
import LinearProgress from '@mui/material/LinearProgress';

import Button from '@mui/material/Button'
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';

import { LineChart } from '@mui/x-charts/LineChart';

import { DateField } from '@mui/x-date-pickers/DateField';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs';

import TextField from '@mui/material/TextField';
import InputAdornment from '@mui/material/InputAdornment';

import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';

const dayjs = require('dayjs');
var isBetween = require('dayjs/plugin/isBetween');
dayjs.extend(isBetween);

const theme = createTheme({
    palette: {
        primary: {
            main: '#512da8',
        },
        secondary: cyan,
        mode: "dark"
    },
});

function MakeChart({ data, predictions, dates, type }) {

    let series;
    if (predictions === null || predictions.length === 1) {
        series =
            [{
                label: type,
                data: data,
                color: theme.palette.primary.main
            }]
    }
    else {
        series =
            [{
                label: type,
                data: data,
                color: theme.palette.primary.main
            },
            {
                label: "Monte Carlo Prediction",
                data: predictions,
                color: theme.palette.secondary.main
            }]
    }

    return (
        <LineChart
            width={500}
            height={300}

            xAxis={[{
                scaleType: 'time',
                data: dates,
            }]}

            series={series}

            sx={{
                '.MuiLineElement-root': {
                    strokeWidth: 2,
                },
                '.MuiMarkElement-root': {
                    display: 'none'
                }
            }}
        />
    )
}

function MakeButton({ type, value, setButton }) {

    const handleChange = (_, newValue) => {
        if (type === "predict" || newValue !== null) {
            setButton(newValue);
        }
    }
    let buttons;
    let orientation;
    if (type === "stock") {
        buttons = [
            <ToggleButton
                key="AAPL"
                value="AAPL">AAPL</ToggleButton>,
            <ToggleButton
                key="AMZN"
                value="AMZN">AMZN</ToggleButton>,
            <ToggleButton
                key="CVX"
                value="CVX">CVX</ToggleButton>,
            <ToggleButton
                key="JPM"
                value="JPM">JPM</ToggleButton>,
            <ToggleButton
                key="LLY"
                value="LLY">LLY</ToggleButton>,
            <ToggleButton
                key="MSFT"
                value="MSFT">MSFT</ToggleButton>,
            <ToggleButton
                key="NVDA"
                value="NVDA">NVDA</ToggleButton>,
            <ToggleButton
                key="PG"
                value="PG">PG</ToggleButton>,
            <ToggleButton
                key="UNH"
                value="UNH">UNH</ToggleButton>,
            <ToggleButton
                key="XOM"
                value="XOM">XOM</ToggleButton>,
        ];
        orientation = "vertical";
    } else if (type === "predict") {
        buttons = [<ToggleButton
            key="Monte_Carlo"
            value="Monte_Carlo">Monte Carlo</ToggleButton>,
        <ToggleButton
            key="Black_Scholes"
            value="Black_Scholes">Black-Scholes</ToggleButton>,
        <ToggleButton
            key="Binomial_Pricer"
            value="Binomial_Pricer">Binomial Pricer</ToggleButton>]
        orientation = "vertical";
    } else if (type === "call_put") {
        buttons = [<ToggleButton
            key="call"
            value="call">Call</ToggleButton>,
        <ToggleButton
            key="put"
            value="put">Put</ToggleButton>]
        orientation = "horizontal";
    }
    else {
        buttons = []
    }

    return (
        <ToggleButtonGroup
            color="primary"
            value={value}
            exclusive
            orientation={orientation}
            onChange={handleChange}
        >{buttons}</ToggleButtonGroup>
    )
}

function MakeDateRange({ start, setStart, end, setEnd }) {

    return (
        <div>
            <DateField
                label="Start Date"
                value={start}
                onChange={(newValue) => {
                    if (newValue.isBetween('1999-03-01', end)) {
                        setStart(newValue)
                    }
                }}
                format="MM-DD-YYYY"
                minDate="1999-03-01"
                maxDate={end} />

            <DateField label="End Date"
                value={end}
                onChange={(newValue) => {
                    if (newValue.isBetween(start, '2018-03-01')) {
                        setEnd(newValue)
                    }
                }}
                format="MM-DD-YYYY"
                minDate={start}
                maxDate="2018-03-01" />
        </div>
    )
}

function MakeTable({ accuracy, expiration, contract, pnl }) {
    return (
        <TableContainer>
            <Table>
                <TableHead>
                    <TableRow>
                        <TableCell>Percent Error (MAPE)</TableCell>
                        <TableCell>Stock Price at Expiration</TableCell>
                        <TableCell>Recomended Contract Price</TableCell>
                        <TableCell>Predicted Profit/Loss</TableCell>
                    </TableRow>
                </TableHead>
                <TableBody>
                    <TableRow>
                        <TableCell align="center">{accuracy}%</TableCell>
                        <TableCell align="center">${expiration}</TableCell>
                        <TableCell align="center">${contract}</TableCell>
                        <TableCell align="center">${pnl}</TableCell>
                    </TableRow>
                </TableBody>
            </Table>
        </TableContainer>
    )
}


export default function Home() {

    // arrays to hold time-series data
    let [dates, setDates] = useState([1]);
    let [stocks, setStocks] = useState([1]);
    let [predictions, setPredictions] = useState([1])

    // what kind of data we're asking the REST API for
    let [stock, setStock] = useState("AAPL");
    let [type, setType] = useState("");

    // what dates we're asking for
    let [start, setStart] = useState(dayjs("2006-01-01"))
    let [end, setEnd] = useState(dayjs("2008-01-01"))
    let [middle, setMiddle] = useState(dayjs("2007-01-01")) // for predictions

    // monte carlo specific variables
    let [accuracy, setAccuracy] = useState(0);

    // black-scholes specific variables
    let [strike, setStrike] = useState(100);
    let [interest, setInterest] = useState(5);
    let [callPut, setCallPut] = useState("call"); // this will always be call or put, lowercase

    // binomial pricer specific variables
    let [timesteps, setTimesteps] = useState(10);

    // options results (black-scholes and binomial pricer)
    let [expiration, setExpiration] = useState(0);
    let [contract, setContract] = useState(0);
    let [pnl, setPnl] = useState(0);

    // for dynamic loading
    let [graphLoading, setGraphLoading] = useState(false);
    let [resultsLoading, setResultsLoading] = useState(false);


    useEffect(function () {


        function to_string(date) {
            return date.toISOString().slice(0, 10);
        }

        setPredictions(([1]))
        setExpiration(0);
        setContract(0);
        setPnl(0);
        setDates([1]);
        setStocks([1]);

        fetch("http://ec2-34-235-103-161.compute-1.amazonaws.com:8181/stock/" + stock + "/" + to_string(start) + "/" + to_string(end))
            .then((response) => {
                return response.json();
            }).then((parsed_response) => {
                const dates =
                    parsed_response.dates.map((date_string) => (
                        new Date(date_string)
                    ));
                setDates(dates);
                setStocks(parsed_response.stocks);
            }).catch((error) => console.log(error));

        if (type === "Monte_Carlo") {
            setGraphLoading(true);
            fetch("http://ec2-34-235-103-161.compute-1.amazonaws.com:8181/Monte_Carlo/" + stock + "/" + to_string(start) + "/" + to_string(middle) + "/" + to_string(end))
                .then((response) => {
                    return response.json();
                }).then((parsed_response) => {
                    setPredictions(parsed_response.predictions);
                    setAccuracy(Math.round(parsed_response.accuracy * 10000) / 100);
                }).catch((error) => console.log(error))
                .finally((_) => setGraphLoading(false));
        }

        else if (type === "Black_Scholes") {
            setResultsLoading(true);
            fetch("http://ec2-34-235-103-161.compute-1.amazonaws.com:8181/Black_Scholes/" + stock + "/" + strike + "/" + (interest / 100) + "/" + to_string(middle) + "/" + to_string(end) + "/" + to_string(start) + "/" + callPut)
                .then((response) => {
                    return response.json();
                }).then((parsed_response) => {
                    setExpiration(parsed_response.stock_expiration_price);
                    setContract(Math.round(parsed_response.option_contract_price * 100) / 100);
                    setPnl(Math.round(parsed_response.pnl * 100) / 100);
                }).catch((error) => console.log(error))
                .finally((_) => setResultsLoading(false));

        } else if (type === "Binomial_Pricer") {
            setResultsLoading(true);
            fetch("http://ec2-34-235-103-161.compute-1.amazonaws.com:8181/Binomial_Pricer/" + stock + "/" + strike + "/" + (interest / 100) + "/" + to_string(middle) + "/" + to_string(end) + "/" + to_string(start) + "/" + callPut + "/" + timesteps)
                .then((response) => {
                    return response.json();
                }).then((parsed_response) => {
                    setExpiration(parsed_response.stock_expiration_price);
                    setContract(Math.round(parsed_response.option_contract_price * 100) / 100);
                    setPnl(Math.round(parsed_response.pnl * 100) / 100);
                }).catch((error) => console.log(error))
                .finally((_) => setResultsLoading(false));
        }



    }, [start, middle, end, type, stock, strike, interest, callPut, timesteps])


    return (
        <div className="App">
            <header className="App-header">
                <h1>🚀 SimBoost 🚀</h1>
                <ThemeProvider theme={theme}>
                    <LocalizationProvider dateAdapter={AdapterDayjs}>
                        <div className="Help_button">
                            <Link to="/Help">
                                <Button color="secondary" variant="outlined"> Help </Button>
                            </Link>
                        </div>
                        <div className="Row">
                            <MakeButton type={"stock"} value={stock} setButton={setStock} />
                            {graphLoading ? <CircularProgress /> : <MakeChart dates={dates} data={stocks} predictions={predictions} type={stock} />}
                            <MakeButton type={"predict"} value={type} setButton={setType} />
                        </div>

                        <h3>General Parameters</h3>
                        <MakeDateRange start={start} setStart={setStart} end={end} setEnd={setEnd} />


                        <h3>Model Parameters</h3>
                        <div>
                            <DateField label="Prediction Start Date"
                                value={middle}
                                onChange={(newValue) => {
                                    if (newValue.isBetween(start, end)) {
                                        setMiddle(newValue)
                                    }
                                }}
                                format="MM-DD-YYYY"
                                minDate={start}
                                maxDate={end} />
                            <TextField label="Strike Price"
                                value={strike}
                                type="number"
                                onChange={(newValue) => {
                                    const { value } = newValue.target;
                                    if (parseFloat(value) > 0) {
                                        setStrike(value)
                                    }
                                }}
                                InputProps={{
                                    startAdornment: <InputAdornment position="start">$</InputAdornment>,
                                }}
                            />
                            <TextField label="Interest Rate"
                                value={interest}
                                type="number"
                                onChange={(newValue) => {
                                    const { value } = newValue.target;
                                    if (parseFloat(value) > 0) {
                                        setInterest(value)
                                    }
                                }}
                                InputProps={{
                                    endAdornment: <InputAdornment position="end">%</InputAdornment>,
                                }}
                            />
                            <MakeButton type={"call_put"} value={callPut} setButton={setCallPut} />
                            <TextField label="Number of Timesteps"
                                value={timesteps}
                                type="number"
                                onChange={(newValue) => {
                                    const { value } = newValue.target;
                                    if (parseInt(value) > 0) {
                                        setTimesteps(value)
                                    }
                                }}
                            />
                        </div>

                        <h3>Model Results</h3>

                        {resultsLoading ? <LinearProgress /> : <MakeTable accuracy={accuracy} expiration={expiration} contract={contract} pnl={pnl} />}

                    </LocalizationProvider>
                </ThemeProvider>

            </header >
        </div >
    );
}