import { useState, useEffect } from 'react';
import './App.css';

import Button from '@mui/material/Button';

import ButtonGroup from '@mui/material/ButtonGroup';

import { LineChart } from '@mui/x-charts/LineChart'

function MakeChart({ stocks, dates }) {
  return (
    <LineChart
      xAxis={[{
        scaleType: 'time',
        data: dates
      }]}
      series={[
        {
          data: stocks
        },
      ]}
      width={500}
      height={300}
      sx={{
        '.MuiLineElement-root': {
          strokeWidth: 2,
        },
        '.MuiMarkElement-root': {
          scale: '0',
        },
      }}
    />
  )
}


function App() {
  let [dates, setDates] = useState([1]);
  let [stocks, setStocks] = useState([1]);
  let [stock, setStock] = useState("AAPL");

  useEffect(function () {
    fetch("http://ec2-34-235-103-161.compute-1.amazonaws.com:8181/stock/" + stock + "/2012-01-01/2013-12-31")
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

  const buttons = [
    <Button
      onClick={() => {
        setStock("AAPL")
      }}
      key="AAPL">AAPL</Button>,
    <Button
      onClick={() => {
        setStock("MSFT")
      }}
      key="MSFT">MSFT</Button>,
    <Button
      onClick={() => {
        setStock("AMZN")
      }}
      key="AMZN">AMZN</Button>,
    <Button
      onClick={() => {
        setStock("TSLA")
      }}
      key="TSLA">TSLA</Button>
  ];


  return (
    <div className="App">
      <header className="App-header">
        <h1>STOCK DASHBOARD RAAH</h1>
        <div className="Row">
          <ButtonGroup
            orientation="vertical"
          >{buttons}</ButtonGroup>
          <MakeChart
            dates={dates} stocks={stocks}
          />
        </div>
      </header>
    </div >
  );
}



export default App;
