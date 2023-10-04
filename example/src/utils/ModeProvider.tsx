import React from 'react';

// Defines the structure for the mode context.
// `selectedMode` keeps track of the currently active mode,
type ModeContextType = {
  selectedMode: string;
  setSelectedMode: (mode: string) => void;
};

// Default values for the ModeContext.
const defaultModeContext: ModeContextType = {
  selectedMode: '',
  setSelectedMode: () => {},
};

// Creates a React context for managing mode selection in the application.
export const ModeContext =
  React.createContext<ModeContextType>(defaultModeContext);

// ModeProvider is a context provider component for `ModeContext`.
// It maintains the state of the selected mode and provides the ability to change it.
// Any components wrapped inside ModeProvider will have access to the current mode and the function to set it.
export const ModeProvider: React.FC = ({ children }) => {
  const [selectedMode, setSelectedMode] = React.useState<string>('');

  return (
    <ModeContext.Provider value={{ selectedMode, setSelectedMode }}>
      {children}
    </ModeContext.Provider>
  );
};
