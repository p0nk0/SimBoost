import { useState, useEffect } from 'react';
import './App.css';

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
  },
});


function MakeChart({ type, data, dates }) {
  return (
    <LineChart
      xAxis={[{
        scaleType: 'time',
        data: dates,
        color: "ffffff"
      }]}
      series={[
        {
          id: "Data",
          label: type,
          data: data,
          color: theme.palette.primary.main
        },
      ]}
      width={500}
      height={300}
      sx={{
        '.MuiLineElement-root': {
          strokeWidth: 2,
          stroke: theme.palette.primary.main
        },
        '.MuiMarkElement-root': {
          display: 'none'
        }
      }}
    />
  )
}

function App() {
  let [dates, setDates] = useState([1]);
  let [stocks, setStocks] = useState([1]);
  let [stock, setStock] = useState("AAPL");
  let [type, setType] = useState("stock");

  useEffect(function () {
    fetch("http://ec2-34-235-103-161.compute-1.amazonaws.com:8181/" + type + "/" + stock + "/2012-01-01/2013-12-31")
      .then((response) => {
        return response.json();
      }).then((parsed_response) => {
        const dates =
          parsed_response.dates.map((date_string) => (
            new Date(date_string)
          ));
        setDates(dates);
        setStocks(parsed_response.stocks);
      });
  }, [stock])

  const handleChange = (_, newStock) => {
    if (newStock !== null) {
      setStock(newStock);
    }
  }

  const buttons = [
    <ToggleButton
      key="AAPL"
      value="AAPL">AAPL</ToggleButton>,
    <ToggleButton
      key="MSFT"
      value="MSFT">MSFT</ToggleButton>,
    <ToggleButton
      key="AMZN"
      value="AMZN">AMZN</ToggleButton>,
    <ToggleButton
      key="TSLA"
      value="TSLA">TSLA</ToggleButton>
  ];


  return (
    <div className="App">
      <header className="App-header">
        <h1>STOCK DASHBOARD RAAH</h1>
        <div className="Row">
          <ThemeProvider theme={theme}>
            <ToggleButtonGroup
              color="primary"
              value={stock}
              exclusive
              orientation="vertical"
              onChange={handleChange}
            >{buttons}</ToggleButtonGroup>
            <MakeChart
              dates={dates} data={stocks} type={stock}
            />
          </ThemeProvider>
        </div>
      </header>
    </div >
  );
}



export default App;
