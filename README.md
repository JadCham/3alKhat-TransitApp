The application “3al Khat” is a demo of the Intelligent Transit API. 


https://github.com/JadCham/Intelligent-Transit


It shows the map of Beirut and gives the user the ability to select his source and his destination. 
Then the app uses the information returned by the API to display the path proposed by the API. 
The whole system does not rely on google API it uses a graph built on the server to return the nodes. 
Then these nodes are used as markers to query the google API to draw the polyline (route).


Instructions:

1- Install Pods from included podfile or requirements below.

2- Change "YOUR_KEY_HERE" in appdelegate.m to your google maps ios sdk key.

3- Change "YOUR_KEY_HERE" in ViewController.m to your google direction server key.


This app uses :

-AFNetworking
-Google-Mobile-Ads-SDK
-GoogleMaps
-SBJson
