## Developer homework for Emarsys(2020)

[![Codeship Status for pigri/emarsys-due-date-calculator-service](https://app.codeship.com/projects/92a3e1d0-395b-0138-4562-0e2f2126edb5/status?branch=master)](https://app.codeship.com/projects/386640)


I dockerized the application to ease the configuration, setup and use.

#### Solution:

* language: lua
* framework: [nginx](https://nginx.com)
* [api response standard](https://google.github.io/styleguide/jsoncstyleguide.xml)
* ci system: [codeship](https://codeship.com)

#### Nginx + Application:

* non-root running
* standard json response
* LuaJIT integrated
* all response header is set up


Run the following commands to set up the development enviroment:

### Mac OS

### Installation

```
brew cask install codeship/taps/jet
brew cask install docker
brew tap openresty/nginx
brew install openresty
cpan install Test::Nginx
cpan install List::MoreUtils
cpan install HTTP::Response
```

### Configuration

#### Nginx config change

```
cp dev_conf/nginx.conf /usr/local/etc/openresty/nginx.conf
```

In the configuration file change this variable `<CHANGE_THIS_PATH>` of your local path.

#### Nginx start

```
brew services start openresty/brew/openresty
```

#### Local build

```
make local_build
```

#### Local test

```
make test
```

#### If just try local

```
docker pull pigri/emarsys-due-date-calculator-service:latest
docker run -p 8080:8080 -d emarsys-due-date-calculator-service
```

### Using

Two fields are required, `issue_start` and `turnaround`.

#### issue_start (string)

Just a date format supported only. Format: `YYYY-MM-DD HH-MM-SS`

#### turnaround (number) or (float)

This parameter says how many working hours needed. Format: `67` or `12.57`

#### Request

```
curl -G -s --data-urlencode "issue_start=2019-09-27 09:00:00"  "localhost:8080/duedate?turnaround=16"
```

#### Response

```
{"data":{"duedate":"2019-09-30 17:00:00"}}
```

#### Request and response pretty version

```
curl -G -s --data-urlencode "issue_start=2019-09-27 09:00:00"  "localhost:8080/duedate?turnaround=16" | jq
```

```
{
  "data": {
    "duedate": "2019-09-30 17:00:00"
  }
}
```
