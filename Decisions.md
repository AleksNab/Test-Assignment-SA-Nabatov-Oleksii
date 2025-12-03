Briefly describe key decisions (3-5 points):
- Why you chose these variables and default values.
- How you connected Nginx and PHP-FPM (socket vs tcp), why - through a socket using fastcgi_pass, because nginx and php-fpm are on the same host, with a shared Docker network, this speeds up the connection and reduces costs.
- How you ensured idempotency in Ansible  -  By checking the status of the application and various modules such as file or service
- What exactly /healthz checks and how - Various monitoring systems check the endpoint and receive a 200 status code, as well as information that the application is working.
- What you would improve given more time - I would put more values in variables, such as application versions and file paths, to make tasks/main.yml as small as possible, so that it would be easier to read and use in the future.
