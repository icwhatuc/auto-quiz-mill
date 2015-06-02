from datetime import datetime
from elasticsearch import Elasticsearch
import urllib3
import requests
import certifi

urllib3.disable_warnings() # disable warnings from bonsai server
res = requests.get("https://mpetgxg8c4:8sl7z9gaui@quiz-9057819005.us-east-1.bonsai.io")

print res.content

#es = Elasticsearch([{'host': 'https://mpetgxg8c4:8sl7z9gaui@quiz-9057819005.us-east-1.bonsai.io'}])
#es = Elasticsearch(['https://mpetgxg8c4:8sl7z9gaui@quiz-9057819005.us-east-1.bonsai.io:9200/'])

es = Elasticsearch(['https://mpetgxg8c4:8sl7z9gaui@quiz-9057819005.us-east-1.bonsai.io:9200'],  
    http_auth = ('user', 'secret'),
    port = 443,
    use_ssl=True,
    verify_certs=True,
    ca_certs=certifi.where());

es.index(index='test', doc_type='question', id=1, body={'name':'q100', 'difficulty':1000, 'question_text': 'What is the meaning of life?'})

print "end"
