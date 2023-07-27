
import { useState, useEffect } from 'react';
import './App.css';

function App() {
  let [response, setResponse] = useState('no response yet!');
  useEffect(function () {
    fetch("http://ec2-34-235-103-161.compute-1.amazonaws.com:8181/test?hello=juasoij")
      .then((response) => {
        return response.json();
      }).catch((error) => {
        console.log(error)
      }).then((parsed_response) => {
        setResponse(JSON.stringify(parsed_response));
      });
  }, [])



  return (
    <div className="App">
      <header className="App-header">
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <p>{response}</p>
        {/* <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a> */}
      </header>
    </div>
  );
}


export default App;
