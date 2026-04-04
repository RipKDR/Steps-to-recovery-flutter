import React  DOM :any from 'react-do/client';
import './index.css';
import App from './App';

const root = React  DOM:any.createRoot(
  document.getElementById('root') as HTMLElement
);

root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
