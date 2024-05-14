# Team Info

```
Dataset Names: 03-movies
Dataset Links
- https://www.kaggle.com/datasets/igorkirko/wwwboxofficemojocom-movies-with-budget-listed
- https://www.kaggle.com/rounakbanik/the-movies-dataset
- https://www.kaggle.com/zeegerman/hollywood-stock-exchange-box-office-data
```

# Folder structure

```
.
├── Code
│   ├── ...
│   ├── Client       # contain your client code
│   ├── SQL          # contain your SQL code
│   └── DataMining   # contain your data mining code
├── Report
│   ├── ...
│   └── report.pdf   # please name it as "report.pdf"
├── VideoDemo
│   ├── ...
│   └── demo.mp4     # please name it as "demo.mp4"
└── README.md
```

# Additional Notes

to initialize db and use CLI:
- login to mySQL server in code/sql directory 
- run connect db356_team31; (change the db name if you are running on a different database)
- run source newload.sql
- exit mysql, run python parser.py in code/sql (if it doesn't recognize, try python3 parser.py). You will need to update the values in the parser.py file for hostname, username, password, and database, which correspond to the MySQL login 
- all data is inititialized, try python projectcli.py in code/client directory. You will need to update the values in the projectCLI.py file for hostname, username, password, and database, which correspond to the MySQL login 

Note: scripts can take a while to run, but it can vary wildly. At December 9th 4 AM, For the newload.sql, I timed 7 minutes. parser.py timed to 33 minutes on the server, but only 7 minutes on local. I tested on marmoset05, but riku seems to be faster from our testing, somehow. Use my login if it takes too long use my login to skip the first four points and load projectcli.py immediately.

```
hostname = 'marmoset05.shoshin.uwaterloo.ca'
username = 'a23memon' 
password = 'db2J3KK^MseUaf58dZ!7'
database = 'db356_team31'
```