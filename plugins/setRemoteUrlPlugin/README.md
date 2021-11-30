For testing the function you have to copy _this_ PlugIn in the 'generic'-Plugin section of your OJS installation.
Activate the PlugIn at **Site-level** in Browser and provide via settings a token.

Now test:

curl -k "https://www.<yourojs>.com?publication_id=123&remote_url=<your DOI URI>&token=<token in Plugin settings>"  

Visit result https://<your ojs server>/<journal which incl. publication_id=123>/api/v1/submissions