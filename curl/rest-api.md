### Curl Jenkins RestAPI Calls
```bash
$ curl -u username:password "http://jenkins-master.url:8080/api/json?tree=views\[name,url,jobs\[name,url,builds\[number,url\]\]\]"
```

```bash
$ curl -u username:password  "http://jenkins-master.url:8080/job/daily_irisn_hawkeye_default_user_gms_release-keys-new04/api/json?tree=jobs\[name,url,builds\[number,url\]\]"
```