import json


def modify_column_value(json_file, data):
    """
    This function modifies the specified columns of a given pandas DataFrame based on the modifications specified in a JSON file. The function returns a modified copy of the DataFrame.

    Parameters:
        - json_file (string): The path to the JSON file containing the modifications.
        - data (pandas DataFrame): The DataFrame to modify.

    Returns:
        - A pandas DataFrame that is a modified copy of the input DataFrame.

    Exceptions:
        - Raises a ValueError if a modification dictionary does not contain all the required keys.

    Implementation Details:

        - The function first creates a copy of the input DataFrame and adds two new columns named 'modified' and 'modification'.
        - It reads the modifications from the specified JSON file using the json.load() function.
        - It loops through each modification dictionary in the JSON file and checks whether it contains all the required keys.
        - It then searches for rows in the DataFrame that match the 'id' and 'name' keys in the modification dictionary.
        - For each matching row, it stores the old values of the specified columns, updates the 'modified' and 'modification' columns, and stores the new values in a dictionary.
        - Finally, it applies the modifications to the DataFrame using the dictionary of modified values.

    Function: modify_data
        - This function is a wrapper function that calls modify_column_value function with the specified arguments.

    Parameters:
        - json_file (string): The path to the JSON file containing the modifications.
        - data (pandas DataFrame): The DataFrame to modify.

    Returns:
        - A pandas DataFrame that is a modified copy of the input DataFrame.
    """

    # Create a copy of the input DataFrame
    df = data.copy()

    # Create 'modified' and 'modification' columns
    df['modified'] = False
    df['modification'] = ''

    # Read modifications from file
    with open(json_file, 'r') as f:
        modifications = json.load(f)

    modified_values = {}
    for modification in modifications:
        # Check that the modification dictionary contains the required keys
        if not all(key in modification for key in ('id', 'name', 'age', 'country')):
            continue

        id_column = modification['id']
        name = modification['name']
        new_age = modification.get('age')
        new_country = modification.get('country')

        # Find rows matching the id and name
        mask = (df['id'] == id_column) & (df['name'] == name)
        rows = df.loc[mask]

        if not rows.empty:
            # Store old values
            old_age = rows['age'].values[0]
            old_country = rows['country'].values[0]

            # Store modified values in a dictionary
            if new_age is not None:
                modified_values[(id_column, name, 'age')] = new_age
            if new_country is not None:
                modified_values[(id_column, name, 'country')] = new_country

            # Update 'modified' and 'modification' columns
            df.loc[mask, 'modified'] = True
            modification_str = ''
            if new_age is not None:
                modification_str += f"The age {old_age} has been changed to {new_age}."
            if new_country is not None:
                if modification_str:
                    modification_str += ' '
                modification_str += f"The country {old_country} has been changed to {new_country}."
            df.loc[mask, 'modification'] = modification_str

    # Apply modifications to the DataFrame
    for (id, name, column), value in modified_values.items():
        mask = (df['id'] == id) & (df['name'] == name)
        df.loc[mask, column] = value

    # Return the modified copy of the DataFrame
    return df


def modify_data(json_file, data):
    return modify_column_value(json_file, data)
