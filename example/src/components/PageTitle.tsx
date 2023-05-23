import React from 'react';
import { StyleSheet, Text, useColorScheme, View } from 'react-native';
import { Colors } from 'react-native/Libraries/NewAppScreen';

/**
 * A component for a page title.
 * @param title The page title.
 * @returns The page title component.
 */
export const PageTitle: React.FC<{
  title: string;
}> = ({ title }) => {
  const isDarkMode = useColorScheme() === 'dark';
  return (
    <View style={styles.pageTitleContainer}>
      <Text
        style={[
          styles.pageTitle,
          {
            color: isDarkMode ? Colors.white : Colors.black,
          },
        ]}
      >
        {title}
      </Text>
    </View>
  );
};

/**
 * Styles for the component.
 */
const styles = StyleSheet.create({
  pageTitleContainer: {
    marginVertical: 20,
  },
  pageTitle: {
    fontSize: 32,
    fontWeight: '600',
    textAlign: 'center',
  },
});
