import pycurl, json, urllib2

#site = urllib2.urlopen("www.google.com/trends/hottrends/hotItems/ajax=1&htd=20131111&pn=p1&htv=l").read()
#print(site)

url = "www.google.com/trends/hottrends/hotItems/ajax=1&htd=20131111&pn=p1&htv=l"
c = pycurl.Curl()
c.setopt(c.URL, url)
c.setopt(c.WRITEFUNCTION, buf.write)
c.perform()

print buf.getvalue()
buf.close
