from datetime import datetime
from elasticsearch import Elasticsearch
import urllib3
import requests

urllib3.disable_warnings() # disable warnings from bonsai server
res = requests.get("https://mpetgxg8c4:8sl7z9gaui@quiz-9057819005.us-east-1.bonsai.io")

print res.content

#es = Elasticsearch([{'host': 'https://mpetgxg8c4:8sl7z9gaui@quiz-9057819005.us-east-1.bonsai.io'}])
es = Elasticsearch(['https://mpetgxg8c4:8sl7z9gaui@quiz-9057819005.us-east-1.bonsai.io:9200/'])

es.index(index='test', doc_type='question', id=1, body={'name':'q100', 'difficulty':1000, 'question_text': 'What is the meaning of life?'})

print "end"

"""
es = Elasticsearch()

doc = {
    'author': 'kimchy',
    'text': 'Elasticsearch: cool. bonsai cool.',
    'timestamp': datetime(2010, 10, 10, 10, 10, 10)
}
res = es.index(index="test-index", doc_type='tweet', id=1, body=doc)
print(res['created'])

res = es.get(index="test-index", doc_type='tweet', id=1)
print(res['_source'])

es.indices.refresh(index="test-index")

res = es.search(index="test-index", body={"query": {"match_all": {}}})
print("Got %d Hits:" % res['hits']['total'])
for hit in res['hits']['hits']:
    print("%(timestamp)s %(author)s: %(text)s" % hit["_source"])
"""