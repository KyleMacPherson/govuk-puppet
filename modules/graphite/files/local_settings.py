# Edit this file to override the default graphite settings, do not edit settings.py!!!

from os.path import dirname, abspath

# Turn on debugging and restart apache if you ever see an "Internal Server Error" page
DEBUG = True

# Fix graphite's broken settings.py
WEB_DIR = dirname( abspath(__file__) ) + '/'
WEBAPP_DIR = dirname( dirname(WEB_DIR) ) + '/webapp/'
CONTENT_DIR = WEBAPP_DIR + 'content/'
CSS_DIR = CONTENT_DIR + 'css/'

# Set your local timezone (django will *try* to figure this out automatically)
# If your graphs appear to be offset by a couple hours then this probably
# needs to be explicitly set to your local timezone.
TIME_ZONE = 'Europe/London'

# Override this if you need to provide documentation specific to your graphite deployment
#DOCUMENTATION_URL = "http://wiki.mycompany.com/graphite"
