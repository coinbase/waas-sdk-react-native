// components/AppContext.js
import React from 'react';

export type Context = {
  apiKeyName?: string;
  privateKey?: string;
};

const AppContext = React.createContext<Context>({});

export default AppContext;
