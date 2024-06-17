#!/bin/bash

# List of IP addresses to ping
ips=("192.168.10.3" "192.168.10.90" "192.168.10.2")

while true; do
    clear
    # Loop through each IP address and ping it
    for ip in "${ips[@]}"; do
        echo "Pinging $ip."

        # Ping the IP once and capture the output
        ping_output=$(ping -c 1 $ip)

        # Check if the ping was successful
        if [ $? -eq 0 ]; then
            echo "Ping successful."

            # Extract and display the mdev value
            mdev=$(echo "$ping_output" | grep "time=" | awk -F'=' '{print $4}' | cut -d ' ' -f 1)
            echo "$mdev ms"
        else
            echo "Ping to $ip failed."
            # Log the error to Excel file using Python
            python3 - <<END
import xlsxwriter
from datetime import datetime

ip = "$ip"
date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

workbook = xlsxwriter.Workbook('ping_errors.xlsx')
worksheet = workbook.add_worksheet()

# Write headers
worksheet.write(0, 0, 'IP in Error')
worksheet.write(0, 1, 'Date of Error')

# Write data
worksheet.write(1, 0, ip)
worksheet.write(1, 1, date)

workbook.close()
END
        fi

        echo "--------------------------------"
    done
    
    # Sleep for 1 second before reloading
    sleep 1
done