import React from 'react';
// Default values for the ModeContext.
const defaultModeContext = {
    selectedMode: '',
    setSelectedMode: () => { },
};
// Creates a React context for managing mode selection in the application.
export const ModeContext = React.createContext(defaultModeContext);
// ModeProvider is a context provider component for `ModeContext`.
// It maintains the state of the selected mode and provides the ability to change it.
// Any components wrapped inside ModeProvider will have access to the current mode and the function to set it.
export const ModeProvider = ({ children }) => {
    const [selectedMode, setSelectedMode] = React.useState('');
    return (React.createElement(ModeContext.Provider, { value: { selectedMode, setSelectedMode } }, children));
};
