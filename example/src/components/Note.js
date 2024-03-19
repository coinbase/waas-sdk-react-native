import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
/**
 * A component for displaying a note section.
 * @param children The content to display in the note.
 * @param items An optional array of items to render in a numbered list.
 * @returns The note component.
 */
export const Note = ({ children, items }) => {
    const renderItem = (item, index) => (React.createElement(View, { key: index, style: styles.listItem },
        React.createElement(Text, { style: [styles.listItemNumber, styles.noteText] },
            index + 1,
            "."),
        React.createElement(Text, { style: [styles.listItemText, styles.noteText] }, item)));
    const renderContent = () => {
        if (typeof children === 'string') {
            return (React.createElement(React.Fragment, null,
                React.createElement(Text, { style: styles.noteText }, children),
                items && (React.createElement(View, { style: styles.listContainer }, items.map((item, index) => renderItem(item, index))))));
        }
        else if (Array.isArray(children)) {
            return (React.createElement(React.Fragment, null,
                children.map((child, index) => (React.createElement(Text, { key: index, style: styles.noteText }, child))),
                items && (React.createElement(View, { style: styles.listContainer }, items.map((item, index) => renderItem(item, index))))));
        }
        else {
            return children;
        }
    };
    return React.createElement(View, { style: styles.container }, renderContent());
};
/**
 * Styles for the component.
 */
const styles = StyleSheet.create({
    container: {
        backgroundColor: '#fff8dc',
        borderColor: '#ffeb9c',
        borderWidth: 1,
        borderRadius: 4,
        padding: 8,
        marginBottom: 16,
    },
    noteText: {
        fontSize: 16,
        color: '#333',
        fontStyle: 'italic',
    },
    listContainer: {
        marginTop: 8,
    },
    listItem: {
        flexDirection: 'row',
        alignItems: 'flex-start',
        marginBottom: 4,
    },
    listItemNumber: {
        marginRight: 4,
        fontSize: 14,
        color: '#333',
    },
    listItemText: {
        flex: 1,
        fontSize: 14,
        color: '#333',
        marginLeft: 4,
    },
});
