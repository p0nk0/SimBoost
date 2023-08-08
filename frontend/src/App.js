import { BrowserRouter, Routes, Route } from "react-router-dom";
import Home from "./pages/Home";
import Help from "./pages/Help";
export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/">
          <Route index element={<Home />} />
          <Route path="help" element={<Help />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}