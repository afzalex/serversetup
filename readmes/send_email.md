# Send email with python code


## To send simple text email
```python
import smtplib, ssl
from getpass import getpass

port = 465  # For SSL
sender_email="afzalex.store@gmail.com"
def send_text_mail(receiver_email, password, message, sender_email=sender_email):
    smtp_server = "smtp.gmail.com"

    context = ssl.create_default_context()
    with smtplib.SMTP_SSL(smtp_server, port, context=context) as server:
        server.login(sender_email, password)
        server.sendmail(sender_email, receiver_email, message)

receiver_email = "afzalex.testing@gmail.com"  # Enter receiver address
password = getpass("Type your password and press enter: ")
message = """\
Subject: Hi there

This message is sent from Python.
"""
send_text_mail(receiver_email, password, message)
```

## How to get password to send mail
To run above code with gmail **Application Specific Password** is required.  
To create application specific password :
1. Browse to [myaccount.google.com](https://myaccount.google.com) and login with your gmail account or [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords) to step 4
2. Navigate from left navigation bar to **Security**
3. Search for **Signing in to Google** and then **App Password**
4. In 'Select app' choose 'Other' with any name e.g. 'My Python Program'
5. Click on **Generate** button
6. Save this password at a secure place.

e.g.
gzmuqzxysmqxlujx



## Send multipart mail or html mail
```python
import smtplib, ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from getpass import getpass

port = 465  # For SSL
sender_email="afzalex.store@gmail.com"

receiver_email = "afzalex.testing@gmail.com"  # Enter receiver address
password = getpass("Type your password and press enter: ")


mail_subject = "Test Multipart Mail"
# Create the plain-text and HTML version of your message
text_message = """\
Hi,
How are you?
Real Python has many great tutorials:
www.realpython.com
"""
html_message = """\
<html>
  <body>
    <p>Hi,<br>
       How are you?<br>
       <a href="http://www.realpython.com">Real Python</a> 
       has many great tutorials.
    </p>
  </body>
</html>
"""

def send_mail(receiver_email, password, subject, text_message, html_message, sender_email=sender_email):
    message = MIMEMultipart("alternative")
    message["Subject"] = subject
    message["From"] = sender_email
    message["To"] = receiver_email
    # Turn these into plain/html MIMEText objects
    part1 = MIMEText(text_message, "plain")
    part2 = MIMEText(html_message, "html")
    # Add HTML/plain-text parts to MIMEMultipart message
    # The email client will try to render the last part first
    message.attach(part1)
    message.attach(part2)
    # Create secure connection with server and send email
    context = ssl.create_default_context()
    with smtplib.SMTP_SSL("smtp.gmail.com", port, context=context) as server:
        server.login(sender_email, password)
        server.sendmail(sender_email, receiver_email, message.as_string())

send_mail(receiver_email, password, mail_subject, text_message, html_message)

```

## Send mail with attachment
```python
import email, smtplib, ssl

from email import encoders
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from getpass import getpass

port = 465  # For SSL
sender_email="afzalex.store@gmail.com"

receiver_email = "afzalex.testing@gmail.com"  # Enter receiver address
password = getpass("Type your password and press enter: ")

subject = "An email with attachment from Python"
body = "This is an email with attachment sent from Python"
attachment_filename = "samples/programming-wallpaper.jpeg"

def send_mail_with_attachment(receiver_email, password, subject, text_message, attachment_filename, sender_email=sender_email):
    # Create a multipart message and set headers
    message = MIMEMultipart()
    message["From"] = sender_email
    message["To"] = receiver_email
    message["Subject"] = subject
    message["Bcc"] = receiver_email  # Recommended for mass emails
    
    # Add body to email
    message.attach(MIMEText(text_message, "plain"))
    
    # Open PDF file in binary mode
    with open(attachment_filename, "rb") as attachment:
        # Add file as application/octet-stream
        # Email client can usually download this automatically as attachment
        part = MIMEBase("application", "octet-stream")
        part.set_payload(attachment.read())
    
    # Encode file in ASCII characters to send by email    
    encoders.encode_base64(part)
    
    # Add header as key/value pair to attachment part
    part.add_header(
        "Content-Disposition",
        f"attachment; filename= {attachment_filename}",
    )
    
    # Add attachment to message and convert message to string
    message.attach(part)
    text = message.as_string()
    
    # Log in to server using secure context and send email
    context = ssl.create_default_context()
    with smtplib.SMTP_SSL("smtp.gmail.com", port, context=context) as server:
        server.login(sender_email, password)
        server.sendmail(sender_email, receiver_email, text)


send_mail_with_attachment(receiver_email, password, subject, body, attachment_filename)
```

## Send mail with library
There are several libraries which make sending mail very easy.
Here is an example of using yagmail
```python
import yagmail
from getpass import getpass

body="Hello there from Yagmail"
attachment_filename = "samples/programming-wallpaper.jpeg"

yag = yagmail.SMTP("afzalex.store@gmail.com", getpass("Type your password and press enter: "))
yag.send(
to="afzalex.testing@gmail.com",
subject="Yagmail test with attachment",
contents=body, 
attachments=attachment_filename,
)
```