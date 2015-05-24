import pycurl, json, urllib2, StringIO

#site = urllib2.urlopen("www.google.com/trends/hottrends/hotItems/ajax=1&htd=20131111&pn=p1&htv=l").read()
#print(site)

buf = StringIO.StringIO()
url = "http://www.google.com/trends/hottrends/hotItems?ajax=1&pn=p1&htv=m"
c = pycurl.Curl()
c.setopt(c.URL, url)
c.setopt(c.WRITEFUNCTION, buf.write)
c.perform()

#print buf.getvalue()
jsonString = buf.getvalue()
jsonObject = json.loads(jsonString)
#print jsonObject
print jsonObject['weeksList'][0]['daysList'][1]['data']['trend']['title']

for week in jsonObject['weeksList']:
    #print weeksList['daysList']
   # exit()
    #for day in weeksList:
    #print "----------week" + week['daysList'][2]['data']['trend']['title']
    for day in week['daysList']:
        #print day['date']#['data']['trend']['title']
        if 'data' in day:
            print day['data']['trend']['title']
        #exit()
        #for trend in day:
            #print trend
                #print daysList[day]['data']['trend']['title']

buf.close

