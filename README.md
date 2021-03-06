# Jarvis 
A Home Surveillance Face Recognition System

## What is Jarvis?

The growing popularity of self-installable surveillance camera devices indicates, that commercially available, traditional home security systems became a less convenient deal for consumers due to their high monthly fees and installation cost. In this project, a secure face recognition equipped home surveillance system is proposed, that can be deployed on a cheap single board computer such as the Raspberry Pi.

<p align="center">
    <img src="https://raw.githubusercontent.com/Kolos65/Jarvis/main/screenshot1.png" width="800"  alt="Screenshot1" />
</p>

The implemented system contains a two modules. The camera module uses **computer vision** algorithms to analyse the captured video frames in **real-time** and exposes the analysed data over a **REST API** implemented as a **Flask** server. The client is an **iOS application**, that is able to control the camera system, receive **push notifications** of detected events and display the live video feed of the camera.

<p align="center">
    <img src="https://raw.githubusercontent.com/Kolos65/Jarvis/main/screenshot2.png" width="800"  alt="Screenshot2" />
</p>


 ## Architecture
 Divided by functionality, the system can be split into three main components. The camera module is responsible for recording and processing frames from a physical camera device, in this case a **Raspberry Pi Camera V2**. The recorded raw frames are processed and analysed using **Python** and **OpenCV**, in order to recognize important security events such as **motion** or the **presence of an unknown face**.
<p align="center">
    <img src="https://raw.githubusercontent.com/Kolos65/Jarvis/main/architecture.png" width="800"  alt="Architecture" />
</p>
The server module implements a REST API, that is used by the mobile application to interfere with the camera and to display a live camera feed to the user. The client was implemented as an iOS application, and is responsible for displaying the raw video footage, accepting push notifications and implementing UI controls, that can modify the settings of the camera module.


## Authentication
Authentication was implemented using <a href="https://developer.apple.com/sign-in-with-apple/get-started/">Sign in with Apple</a>. After successful authentication, the server issues a new <a href="https://jwt.io/">JWT token</a> to the client, which is used in subsequent requests for authentication. The authentication flow is demonstrated on the following figure:

<p align="center">
    <img src="https://raw.githubusercontent.com/Kolos65/Jarvis/main/signinapple.png" width="800"  alt="SignInApple" />
</p>

 ## Deployment
 There are six steps needed to deploy the system on a new Raspberry Pi at a home setup. The prerequisites are quite obvious: a Raspberry Pi, a Raspberry Pi Camera or a webcam connected to the Pi and an iPhone. The steps are the following:

 ### 1. Environment Setup
 Before building the main Docker image of the Camera module, you need to configure some required environment variables. Create a `.env` file in the root folder of the Camera module and add the following environment variables:
 * **ONLY_VALID_EMAIL**: The iOS client uses <a href="https://developer.apple.com/sign-in-with-apple/get-started/">Sign in with Apple</a> for authenticatation. Since this is a DIY home server, the authentication process is simplified to matching against a whitelist of Apple IDs on each login attempt. In the current implementation, this is given by an environment variable that holds the only valid Apple ID (email), that is authorized to access the camera footage.
 * **APP_BUNDLE_ID**: This holds, the <a href="https://developer.apple.com/documentation/appstoreconnectapi/bundle_ids">Bundle ID</a> of the iOS application and is required to validate the Sign in with Apple token.
 * **ISSUER**: This variable will be used to set the Issuer field of the <a href="https://jwt.io/">JWT token</a> generated by the Flask server. This can be an arbitrary name for your server.
 * **JWT_SECRET_KEY**: This should be a cryptographically random secret key <a href="https://docs.python.org/3/library/secrets.html">genrated for example in Python</a>, that is used to issue JWT tokens after successful authentication.
 * **ONE_SIGNAL_APP_ID**: The server uses OneSignal to send push notifications to the iOS application. In order to do that, you need a OneSignal project with an app id to identify your app. You can create a new project for free on <a href="https://onesignal.com/"> OneSignal</a>. After creating a new app, you can find your App ID in the Keys and IDs section of your OneSignal dashboard.
 * **ONE_SIGNAL_API_KEY**: The OneSignal API Key that is used to authorize the API calls to OneSignal. This can also be found in the Keys and IDs section of your OneSignal account.

An example `.env` file would look like the following:

```dosini
ONLY_VALID_EMAIL="email@example.com"
APP_BUNDLE_ID="com.example.bundleid"
ISSUER="my-jarvis-server"
JWT_SECRET_KEY="lkasdjfhlkdsjfhlksdjfh34827rwudzszxcgy78q3refo713"
ONE_SIGNAL_APP_ID="alkefwho3827zuflufhgoqiuwzfglfgiqeuglfigflqiewu"
ONE_SIGNAL_API_KEY="kjalhfsi8uerqfkASDFHJDHFIfqgkufADHSFJGHUFEQKu74t8r2i"
```

With our environment set up, the only thing left before deploying the Camera module is adding your face to the system. To do this, you should: 
1. change `obama.jpg` from the `Camera/assets` folder to an image of your face
2. change the name and image source in `Camera/src/recognizer.py` to your name and the previously added image file
3. search and replace **"Obama"** to your name in `Camera/src/event_handler.py`
4. change the notification title and message to your taste in `Camera/src/event_handler.py` in the `process_face_event` function.

The Flask server is deployed to production with <a href="https://gunicorn.org/">gunicorn</a>, a production Python WSGI HTTP server, but you can test it on your computer using the built in Flask debug server by installing all libraries from requirements.txt, uncommenting the debug server related lines in `main.py` and running `python3 main.py`. After setting up the environment, the Camera module is now ready for deployment, so you can copy the configured folder onto the Raspberry Pi.

 ### 2. Setup a Reverse HTTPS Proxy
To increase the security of the system, the Flask server should be deployed behind a simple HTTPS reverse proxy. You can do that in a couple of minuteds using **Docker**. Create a new folder on the Raspberry Pi called `Proxy` and add a new file called `default.conf`. This will be the configuration file for our proxy server. A basic https configuration file, that redirects all traffic to our Flask server would look like this:
```nginx
server {
    listen 443 ssl;
    server_name localhost;
    
    ssl_certificate /etc/ssl/certs/nginx/jarvis.cert;
    ssl_certificate_key /etc/ssl/certs/nginx/jarvis.key;
    
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    location /jarvis {
        proxy_redirect off;
        proxy_connect_timeout 180;
        rewrite /jarvis/(.*) /$1 break;
        proxy_pass http://jarvis:3000;
        proxy_set_header Host $host;
    }
}
```

After creating the configuration file, add a folder called `ssl` and add an ssl certificate with the corresponding private key to it. You can generate a self signed certificate with openssl and **manually trust the certificate on your iOS device**, or <a href="https://support.apple.com/guide/keychain-access/create-your-own-certificate-authority-kyca2686/mac">set up a custom certificate authority</a> and trust the root certificate of that CA. To generate a self-signed certificate with openssl, run:
```bash
openssl req -x509 -newkey rsa:4096 -keyout key.key -out cert.cert -days 365
```

After creating the necessary configuration files, we can add a simple `Dockerfile` that we will use to create the proxy server's image:
```Dockerfile
FROM nginx:1.19.10

# Default config
COPY ./default.conf /etc/nginx/conf.d/default.conf

# SSL config
COPY ./ssl/ /etc/ssl/certs/nginx/
```

 ### 3. Deploy the Server and the Proxy on the Raspberry Pi
 After our Camera module and HTTPS Proxy is ready to go, we can finally deploy the system on our Raspberry Pi. The first step is to build the Docker images of the two components. You can build the Camera module by running the following command in the root folder:
 ```bash
 docker build -t jarvis .
 ```
 Similarly, you can build the HTTPS Proxy image by running the following command in the previously created `Proxy` folder:
 ```bash
 docker build -t proxy .
 ```
With the Docker images ready, we can now add a `docker-compose.yml` file, that will implement the necessarry configurations to deploy the Camera module with access to the camera device and expose the proxy server on the local network. The two images are deployed on the same Docker network so the proxy can redirect the requests to the Flask server.
```yaml
version: '3.9'
services:
    jarvis:
        image: jarvis
        restart: unless-stopped
        container_name: jarvis
        devices:
            - /dev/video0:/dev/video0
        networks:
            home:
                aliases: 
                    - jarvis
    nginx:
        image: proxy
        restart: unless-stopped
        networks:
            home:
                aliases:
                    - proxy
        ports:
            - 80:80
            - 443:443

networks:
    home:
```

You can now **deploy the system** on the local network using the following command in the same folder as the `docker-compose.yaml` file:
```bash
docker-compose up -d
```
 ### 4. Deploy a VPN server on your Pi
 After successfully running the Camera server on our local network, we need to expose it to the public internet in order to access it remotely. The safest and most recommended way to do that is to create a local VPN server and access our local network (and the Camera server) over a VPN tunnel. The easiest way run a VPN server on the Pi is to use <a href="https://www.pivpn.io/">PiVPN</a>, which is a set of shell scripts, that serve to easily turn your Raspberry Pi into a VPN server using two free, open-source protocols: <a href="https://www.wireguard.com/">WireGuard</a> and <a href="https://openvpn.net/">OpenVPN</a>. If you follow the <a href="https://docs.pivpn.io/">documentation</a>, you will be able to set up a VPN server on your Pi in minutes. After successfully running a VPN server on your Raspberry Pi, you need to download a VPN client to your iOS device and set up your credentials to connect to your home network.

 ### 5. Setup a Dynamic DNS service
 After running the VPN server, you need to forward incoming traffic from your router's IP address to the Raspberry Pi (assuming, you have IPv4). This process is called <a href="https://en.wikipedia.org/wiki/Port_forwarding">port forwarding</a> and can be easily done by changing the router's configuration settings. Don't forget to set up static DHCP for your Raspberry Pi, so the internal IP address of the Pi won't change. After setting up port forwatding, you can access your local network over a VPN tunnel using a desired VPN client. The problem is, that your public IPv4 address can change over time, which would require you to reconfigure your client app and your VPN settings every time. To solve this, you can sign up for a <a href="https://www.dynu.com/">free dynamic DNS service</a>, that will keep track of your IP address and give you a domain name you can use to reach your home network. For the dynamic DNS to work, you need to <a href="https://www.dynu.com/DynamicDNS/IPUpdateClient/RaspberryPi-Dynamic-DNS">set up a simple cron job</a>, that runs a shell script, which updates your IP address with a simple API call. If you use Dynu, this would look like the following:
 ```bash
 echo url="https://api.dynu.com/nic/update?..." | curl -k -o /dynu.log -K -
 ```

 ### 6. Configure the iOS Client
Lastly, with our VPN server and dynamic DNS set up, we can configure the iOS app with the required settings. Go to the `Client/Jarvis` folder and add two files named `Debug.xcconfig` and `Release.xcconfig`. These configuration files will hold the required environment variables for our app to work. Open `Debug.xcconfig` and `Release.xcconfig` and paste the following:
```
#include "Pods/Target Support Files/Pods-Jarvis/Pods-Jarvis.debug.xcconfig"

HOST_URL = https:/$()/YOUR_DYNAMIC_DNS_DOMAIN_NAME/jarvis
ONE_SIGNAL_APP_ID = YOUR_ONESIGNAL_APP_ID
```
where
* **YOUR_DYNAMIC_DNS_DOMAIN_NAME** is the domain name you have set up with your dynamic DNS provider
* **YOUR_ONESIGNAL_APP_ID** is the OneSignal App ID of your previously created OneSignal project
If you wish, you can use the debug scheme to connect to your Raspberry Pi directly over the local network. In this case, change the HOST_URL to your local Raspberry Pi IP address in debug.xcconfig.

With the iOS configuration done, after running `pod install`, **you can now build and run the app on your iOS device** and watch the live footage of your camera over a secure VPN tunnel.