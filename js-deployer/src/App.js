import './App.css';
import React from "react";
import { BrowserRouter, Switch, Route, Redirect } from "react-router-dom";
import DeployMarketplace from "./DeployMarketplace";

const App = () => (
  <BrowserRouter>
    <Switch>
      <Route path="/deploymarketplace" component={DeployMarketplace} exact />
      <Redirect to="/" />
    </Switch>
  </BrowserRouter>
);

export default App;