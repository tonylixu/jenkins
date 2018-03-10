### Curl Jenkins RestAPI Calls
```bash
$ curl -u username:password "http://jenkins-master.url:8080/api/json?tree=views\[name,url,jobs\[name,url,builds\[number,url\]\]\]"
```
