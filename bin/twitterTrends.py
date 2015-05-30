#!/usr/bin/env python

import twitter

# Twitter Dev Info
api = twitter.Api(consumer_key='8AqRYPTl1iESFCF2TipE0fJf2',
                      consumer_secret='grnSaiITDaAcimjyrrffa2iGWoJzjMJVtg4KroQ6f0JaAnEdHU',
                      access_token_key='2710991833-sjFdmiJe6A5rb1uHHoMsHYnnjhBIeWaPifyiTta',
                      access_token_secret='hSUZM3X0lp9L7KQkklDqkx3IEa3VSqEH1sD7NouNHSMpL')

#print api.VerifyCredentials()

#Woeid of New York = 2459115
trend = api.GetTrendsWoeid(2459115)

print trend

