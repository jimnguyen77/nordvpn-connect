#!/bin/bash

# Attempt to connect to NordVPN
connect_output=$(nordvpn c 2>&1)

# Check if the output indicates that the user is not logged in
if [[ "$connect_output" == *"You are not logged in."* ]]; then
    # User is not logged in, attempt to login
    login_output=$(nordvpn login 2>&1)
    echo "$login_output"
    
    # Output the message to the user and prompt for the "success URL"
    echo "Please enter the 'Success URL' after completing the login from the browser:"
    read -p "Success URL: " success_url
    
    # Extract the "exchange_token" from the success URL
    exchange_token=$(echo "$success_url" | grep -oP '(?<=exchange_token=)[^&]*')

    # Check if the exchange_token was successfully extracted and decoded
    if [ -z "$exchange_token" ]; then
        echo "Failed to extract 'exchange_token' from the URL."
        exit 1
    fi

    # Attach the extracted and decoded "exchange_token" to the login command
    login_callback_output=$(nordvpn login --callback "nordvpn://login?exchange_token=$exchange_token" 2>&1)
    echo "Success! Connecting..."
 
    # Re-attempt to connect to NordVPN
    connect_output=$(nordvpn c 2>&1)
fi

echo "$connect_output"
