import { useState, useEffect } from 'react';
import '../App.css';

import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';

import { LineChart } from '@mui/x-charts/LineChart';

import { createTheme, ThemeProvider } from '@mui/material/styles';
import { cyan } from '@mui/material/colors';

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
    if (predictions == null || predictions.length == 1) {
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
    } else if (type === "predict") {
        buttons = [<ToggleButton
            key="Monte_Carlo"
            value="Monte_Carlo">Monte Carlo</ToggleButton>,
        <ToggleButton
            key="Black-Scholes"
            value="Black-Scholes">Black-Scholes</ToggleButton>,]
    } else {
        buttons = []
    }

    return (
        <ToggleButtonGroup
            color="primary"
            value={value}
            exclusive
            orientation="vertical"
            onChange={handleChange}
        >{buttons}</ToggleButtonGroup>
    )
}

export default function Home() {
    let [dates, setDates] = useState([1]);
    let [stocks, setStocks] = useState([1]);
    let [predictions, setPredictions] = useState([1])
    let [stock, setStock] = useState("AAPL");
    let [type, setType] = useState("");
    let [accuracy, setAccuracy] = useState(0);
    let [start, setStart] = useState("2006-01-01")
    let [end, setEnd] = useState("2008-01-01")

    useEffect(function () {

        setDates([1]);
        setStocks([1]);
        fetch("http://ec2-34-235-103-161.compute-1.amazonaws.com:8181/stock/" + stock + "/" + start + "/" + end)
            .then((response) => {
                return response.json();
            }).then((parsed_response) => {
                const dates =
                    parsed_response.dates.map((date_string) => (
                        new Date(date_string)
                    ));
                setDates(dates);
                setStocks(parsed_response.stocks);
            })

        if (type === "Monte_Carlo") {
            setPredictions([1]);
            fetch("http://ec2-34-235-103-161.compute-1.amazonaws.com:8181/Monte_Carlo/" + stock + "/" + start + "/2007-01-01/" + end)
                .then((response) => {
                    return response.json();
                }).then((parsed_response) => {
                    setPredictions(parsed_response.predictions);
                    setAccuracy(Math.round(parsed_response.accuracy * 10000) / 100);
                })
        }

        if (type == null) {
            setPredictions(([1]))
        }

    }, [start, end, type, stock])


    return (
        <div className="App">
            <header className="App-header">
                <h1>STOCK DASHBOARD RAAH</h1>

                <div className="Row">
                    <ThemeProvider theme={theme}>
                        <MakeButton type={"stock"} value={stock} setButton={setStock} />
                        <MakeChart dates={dates} data={stocks} predictions={predictions} type={stock} />
                        <MakeButton type={"predict"} value={type} setButton={setType} />
                    </ThemeProvider>
                </div>
                <h3>General Parameters</h3>
                <ul>
                    Start Date:     End Date:
                </ul>
                <h3>Model Parameters</h3>
                <ul>
                    <li> Monte Carlo: [middle date] </li>
                    <li> Black scholes: [many options] </li>
                </ul>

                <h3>Model Results</h3>
                <p>percent error (MAPE): {accuracy}%</p>
            </header>
        </div >
    );
}